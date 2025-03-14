class CreateTableCustomer < ActiveRecord::Migration[7.1]
  def change
    create_table :customers do |t|
      t.string :first_name
      t.string :last_name
      t.string :phone_number
      t.string :address
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
