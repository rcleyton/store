class CartsController < ApplicationController
  before_action :set_cart

  rescue_from InvalidQuantityError, with: :render_invalid_quantity
  rescue_from ActiveRecord::RecordNotFound, with: :render_record_not_found
  
  def create
    product = Product.find(params[:product_id])
    item = @cart.cart_items.find_or_initialize_by(product: product)
    item.quantity = (item.quantity || 0) + params[:quantity].to_i

    raise InvalidQuantityError, "Quantity must be at least 1" if item.quantity < 1

    item.save! 

    @cart.touch_interaction!
    render_cart
  end

  def show
    render_cart
  end

  def add_item
    product = Product.find(params[:product_id])
    quantity = params[:quantity].to_i

    raise InvalidQuantityError, "Quantity must be at least 1" if quantity < 1

    item = @cart.cart_items.find_by(product: product)

    if item
      item.update!(quantity: item.quantity + quantity)
    else
      item = @cart.cart_items.create!(product:, quantity:)
    end

    @cart.touch_interaction!
    render_cart
  end

  def destroy
    item = @cart.cart_items.find_by(product_id: params[:product_id])

    if item
      item.destroy
      @cart.touch_interaction!
      render_cart
    else
      render json: { error: "Product not found in cart." }, status: :not_found
    end
  end

  private

  def set_cart
    @cart = current_cart
  end

  def render_cart
    render json: { 
      id: @cart.id,
      products: @cart.cart_items.map do |item|
        { 
          id: item.product.id,
          name: item.product.name,
          quantity: item.quantity,
          unit_price: item.product.price,
          total_price: item.total_price
        }
      end,
      total_price: @cart.total_price
    }
  end

  def render_invalid_quantity(exception)
    render json: { error: exception.message }, status: :unprocessable_entity
  end

  def render_record_not_found(_exception)
    render json: { error: "Product not found" }, status: :not_found
  end
end
