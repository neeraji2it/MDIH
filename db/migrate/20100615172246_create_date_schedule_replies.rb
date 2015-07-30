class CreateDateScheduleReplies < ActiveRecord::Migration
  def self.up
    create_table :date_schedule_replies do |t|
      t.integer  :date_schedule_id
      t.integer  :user_id
      t.string   :place
      t.datetime :proposed_date_on
      t.text     :reason
      t.timestamps
    end
  end

  def self.down
    drop_table :date_schedule_replies
  end
end
