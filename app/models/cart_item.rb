class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :quantity, numericality: { greater_than_or_equal_to: 1 }
  
  before_create :set_unit_price
  
  def total_price
    product.price * quantity
  end

  private

  def set_unit_price
    self.unit_price ||= product.price
  end
end
