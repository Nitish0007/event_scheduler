class CreateBookingsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :bookings do |t|
      t.references :customer, null: false, foreign_key: true
      t.references :ticket, null: false, foreign_key: true

      t.integer :quantity, default: 1, null: false

      t.timestamps
    end
  end
end
