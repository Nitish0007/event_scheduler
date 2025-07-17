class ChangeReferencesToUser < ActiveRecord::Migration[7.1]
  def change
    change_table :events do |t|
      t.references :user, foreign_key: true
    end

    change_table :bookings do |t|
      t.references :user, foreign_key: true
    end
  end
end
