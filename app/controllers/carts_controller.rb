class CartsController < ApplicationController
  before_action :set_cart
  
  def create
    product = Product.find(params[:product_id])
    item = @cart.cart_items.find_or_initialize_by(product: product)
    item.quantity = (item.quantity || 0) + params[:quantity].to_i
    item.save! 

    render_cart
  end

  def show
    render_cart
  end

  def add_item
    product = Product.find(params[:product_id])    
    item = @cart.cart_items.find_by(product: product)
    
    if item
      item.update!(quantity: item.quantity + params[:quantity].to_i)
    else
      item = @cart.cart_items.create!(product:, quantity: params[:quantity])
    end

    render_cart
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
end
