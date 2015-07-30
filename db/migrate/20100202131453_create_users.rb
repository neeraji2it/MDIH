class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table "users" do |t|
      t.column :login,                     :string, :limit => 40
      t.column :first_name,                :string, :limit => 40
      t.column :middle_name,               :string, :limit => 40
      t.column :last_name,                 :string, :limit => 40
      t.column :email,                     :string, :limit => 100
      t.column :gender,                    :string, :limit => 6
      t.column :date_of_birth,             :date
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :status,                    :boolean, :default => false
      t.column :role_id,                   :integer
      t.column :activation_code,           :string
      t.column :activated_at,              :datetime
      t.column :password_reset_code,       :string
      t.column :remember_token,            :string, :limit => 40
      t.column :remember_token_expires_at, :datetime
      t.column :crypted_email,             :string, :limit => 40
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
    end
    add_index :users, :login, :unique => true
  end

  def self.down
    drop_table "users"
  end
end
