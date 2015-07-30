class CreateFeedbacks < ActiveRecord::Migration
  def self.up
    create_table :feedbacks do |t|
        t.string :subject, :limit => 32
        t.string :email, :limit => 100
        t.text   :comment
        t.timestamps
      end
  end

  def self.down
    drop_table :feedbacks
  end
end
