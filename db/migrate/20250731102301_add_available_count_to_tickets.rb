class AddAvailableCountToTickets < ActiveRecord::Migration[7.1]
  def change
    add_column :tickets, :available_count, :integer, default: 0
    add_column :bookings, :total_amount, :decimal, precision: 10, scale: 2, default: 0.0
  end
end
