require 'rails_helper'

RSpec.describe CartItem, type: :model do
  context 'when validating' do
    it 'is invalid when quantity is less than 1' do
      cart_item = CartItem.new(unit_price: 10, quantity: 0)
      expect(cart_item).not_to be_valid
      expect(cart_item.errors[:quantity]).to include('must be greater than or equal to 1')
    end
  end
end