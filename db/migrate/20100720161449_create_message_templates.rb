class CreateMessageTemplates < ActiveRecord::Migration
  def self.up
    create_table :message_templates do |t|
      t.column :user_id,          :integer
      t.column :subject,          :text
      t.column :body,             :text
      t.timestamps
    end
  end

  def self.down
    drop_table :message_templates
  end
end
