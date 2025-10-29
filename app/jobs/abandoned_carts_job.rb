class AbandonedCartsJob < ApplicationJob
  queue_as :default

  def perform
    Cart.where(abandoned: false)
        .where('last_interaction_at < ?', 3.hours.ago)
        .find_each do |cart|
          cart.mark_as_abandoned
          puts "Marked as abandoned: Cart #{cart.id}"
        end

    Cart.where(abandoned: true)
        .where('last_interaction_at < ?', 7.days.ago)
        .find_each do |cart|
          cart.remove_if_abandoned
          puts "Removed: Cart #{cart.id}"
        end
  end
end
