class ApplicationController < ActionController::API
  include ActionController::Cookies

  def current_cart
    @cart ||= begin
      if session[:cart_id] && Cart.exists?(session[:cart_id])
        Cart.find(session[:cart_id])
      else
        Cart.last || Cart.create!
      end
    end

    session[:cart_id] = @cart.id
    @cart
  end
end
