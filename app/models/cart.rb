class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  def total_price
    cart_items.sum(&:total_price)
  end

  def mark_as_abandoned
    return if abandoned?

    if last_interaction_at.present? && last_interaction_at < 3.hours.ago
      update!(abandoned: true)
    end
  end

  def remove_if_abandoned
    if abandoned? && last_interaction_at.present? && last_interaction_at < 7.days.ago
      destroy
    end
  end

  def touch_interaction!
    update!(last_interaction_at: Time.current, abandoned: false)
  end
end
