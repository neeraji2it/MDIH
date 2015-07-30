class AddMessageToSentGifts < ActiveRecord::Migration
  def self.up
    add_column :sent_gifts, :message, :string
  end

  def self.down
    remove_column :sent_gifts, :message
  end
end
