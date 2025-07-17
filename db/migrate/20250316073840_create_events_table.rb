class CreateEventsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.string :event_title, null: false
      t.string :event_venue, null: false
      t.datetime :event_date, null: false
      t.bigint :tickets_count, default: 0
      
      t.timestamps
    end
  end
end
