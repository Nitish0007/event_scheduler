class CreatePayments < ActiveRecord::Migration[7.1]
  def change
    create_table :payments do |t|
      t.references :booking, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.decimal :fee, precision: 10, scale: 2, default: 0.0
      t.string :currency, default: 'usd'
      t.integer :status, default: 0
      t.integer :payment_method, default: 0
      t.string :reference_number, null: false
      t.string :stripe_payment_intent_id
      t.string :stripe_charge_id
      t.jsonb :metadata, default: {}
      
      t.timestamps
    end
    
    add_index :payments, :reference_number, unique: true
    add_index :payments, :stripe_payment_intent_id, unique: true
    add_index :payments, :status
    add_index :payments, :created_at
  end
end