require 'rails_helper'

RSpec.describe "/carts", type: :request do
  describe "POST /cart" do
    let(:product) { Product.create(name: "Test Product", price: 10.0) }
    let(:second_product) { Product.create(name: "Test Product 2", price: 15.0) }

    context "session" do
      it 'has no cart' do
        post "/cart", params: { product_id: product.id, quantity: 1 }
        cart_id = JSON.parse(response.body)["id"]

        expected_response = {
          "id" => cart_id,
          "products" => [
            {
              "id" => product.id,
              "name" => "Test Product",
              "quantity" => 1,
              "total_price" => "10.0",
              "unit_price" => "10.0"
            }
          ],
          "total_price" => "10.0"
        }

        expect(session[:cart_id]).to eq(cart_id)
        expect(JSON.parse(response.body)).to eq(expected_response)
      end

      it 'already has cart' do
        post "/cart", params: { product_id: product.id, quantity: 1 }
        first_cart_id = JSON.parse(response.body)["id"]

        post "/cart", params: { product_id: second_product.id, quantity: 2 }
        second_cart_id = JSON.parse(response.body)["id"]
        
        expect(second_cart_id).to eq(first_cart_id)
      end
    end
  end

  describe "GET /cart" do
    let(:product) { Product.create(name: "Test Product", price: 10.0) }

    context "when there is already a cart in the session" do
      it "List items in current cart" do
        post "/cart", params: { product_id: product.id, quantity: 2 }

        json_post = JSON.parse(response.body)
        first_cart_id = json_post["id"]

        get "/cart"
        expect(response).to have_http_status(:ok)

        json_get = JSON.parse(response.body)

        expect(json_get["id"]).to eq(first_cart_id)
        expect(json_get["products"].first["name"]).to eq("Test Product")
        expect(json_get["products"].first["quantity"]).to eq(2)
        expect(json_get["products"].first["unit_price"]).to eq("10.0")
        expect(json_get["total_price"]).to eq("20.0")
      end
    end
  end

  describe "POST /add_item" do
    let(:cart) { Cart.create }
    let(:product) { Product.create(name: "Test Product", price: 10.0) }
    let!(:cart_item) { CartItem.create(cart: cart, product: product, quantity: 1) }

    context 'when the product already is in the cart' do
      subject do
        post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
        post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      it 'updates the quantity of the existing item in the cart' do
        expect { subject }.to change { cart_item.reload.quantity }.by(2)
      end
    end
  end
end
