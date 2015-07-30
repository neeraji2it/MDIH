class ChangeGiftMessageColumnLength < ActiveRecord::Migration
  def self.up
    change_column :sent_gifts, :message, :text
  end

  def self.down
    change_column :sent_gifts, :message, :string
  end
end
