class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.column :subject,          :text
      t.column :body,             :text
      t.column :from,             :integer
      t.column :to,               :integer
      t.column :from_status,      :string, :limit => 20
      t.column :to_status,        :string, :limit => 20
      t.column :replied_to,       :integer
      t.column :created_at,       :datetime
    end
  end

  def self.down
    drop_table :messages
  end
end
