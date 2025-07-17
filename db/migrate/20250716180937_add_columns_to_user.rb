class AddColumnsToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :phone, :string
    add_column :users, :company, :string
    add_column :users, :address, :string

    # adding not null constraint to user_id
    change_column_null :events, :user_id, false
    change_column_null :bookings, :user_id, false
  end
end
