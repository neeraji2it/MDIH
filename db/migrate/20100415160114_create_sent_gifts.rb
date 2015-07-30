class CreateSentGifts < ActiveRecord::Migration
  def self.up
    create_table :sent_gifts do |t|
      t.integer :user_id
      t.integer :product_id
      t.integer :sent_to
      t.datetime :sent_on
      t.string :sender_status, :limit => 10, :default => ""
      t.string :receiver_status, :limit => 10, :default => ""
    end
  end

  def self.down
    drop_table :sent_gifts
  end
end
