class CreateTicketsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :tickets do |t|
      t.string :ticket_type
      t.bigint :event_id, null: false
      t.decimal :price_per_ticket, default: 0, precision: 10, scale: 2, null: false
      t.integer :tickets_count, default: 0
      t.integer :booked_ticket_count, default: 0

      t.timestamps
    end
  end
end
