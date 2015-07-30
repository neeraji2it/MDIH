class CreateEmailSettings < ActiveRecord::Migration
  def self.up
    create_table :email_settings do |t|
      t.integer :user_id
      t.string :alert_type, :limit => 30
      t.boolean :status, :default => false
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :email_settings
  end
end
