class AddAndRemoveColumnsFromMessages < ActiveRecord::Migration
  def change
    add_column :messages,:receiver_id, :integer
    add_column :messages,:receiver_status, :string
    remove_column :messages,:has_replies
    remove_column :messages,:subject
  end
end
