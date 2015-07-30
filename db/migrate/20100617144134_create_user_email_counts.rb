class CreateUserEmailCounts < ActiveRecord::Migration
  def self.up
    create_table :user_email_counts do |t|
      t.integer :sender_id
      t.integer :receiver_id
      t.integer :email_count, :limit => 8, :default => 1
    end
  end

  def self.down
    drop_table :user_email_counts
  end
end
