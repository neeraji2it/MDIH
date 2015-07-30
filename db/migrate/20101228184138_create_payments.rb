class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.integer :user_id
      t.string :ip_address, :limit => 20
      t.string :first_name
      t.string :last_name
      t.string :action
      t.integer :amount
      t.boolean :success
      t.string  :authorization
      t.string  :message
      t.text :params
      t.datetime :created_at

    end
  end

  def self.down
    drop_table :payments
  end
end
