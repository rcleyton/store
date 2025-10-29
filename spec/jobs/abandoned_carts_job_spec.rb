require 'rails_helper'

RSpec.describe AbandonedCartsJob, type: :job do
  let(:active_cart) { Cart.create(last_interaction_at: 1.hour.ago, abandoned: false) }
  let(:inactive_cart) { Cart.create(last_interaction_at: 4.hours.ago, abandoned: false) }
  let(:old_abandoned_cart) { Cart.create(last_interaction_at: 8.days.ago, abandoned: true) }

  it 'marks inactive carts as abandoned' do
    expect {
      AbandonedCartsJob.perform_now
    }.to change { inactive_cart.reload.abandoned? }.from(false).to(true)
  end

  it 'does not mark active carts as abandoned' do
    AbandonedCartsJob.perform_now
    expect(active_cart.reload.abandoned?).to eq(false)
  end

  it 'removes abandoned carts older than 7 days' do
    expect {
      AbandonedCartsJob.perform_now
    }.to change { Cart.exists?(old_abandoned_cart.id) }.from(true).to(false)
  end
end
