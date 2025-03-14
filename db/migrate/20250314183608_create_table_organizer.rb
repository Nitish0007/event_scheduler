class CreateTableOrganizer < ActiveRecord::Migration[7.1]
  def change
    create_table :organizers do |t|
      t.string :first_name
      t.string :last_name
      t.string :phone_number
      t.string :agency_address
      t.string :agency_name
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
