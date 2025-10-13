class AddMoreColsToCourse < ActiveRecord::Migration[8.0]
  def change
    add_column :courses, :paid, :boolean
    add_column :courses, :stripe_price_id, :string
    add_column :courses, :premium_description, :text
  end
end
