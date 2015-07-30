class AddIpaddressToLoginhistory < ActiveRecord::Migration
  def self.up
    add_column :login_histories, :ip_address, :string, :limit => 20
  end

  def self.down
    remove_column :login_histories, :ip_address
  end
end
