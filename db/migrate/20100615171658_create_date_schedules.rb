class CreateDateSchedules < ActiveRecord::Migration
  def self.up
    create_table :date_schedules do |t|
      t.integer  :user_id
      t.integer  :dater_id
      t.datetime :proposed_date_on
      t.datetime :date_on
      t.string   :user_status, :limit => 20
      t.string   :dater_status, :limit => 20
      t.string   :proposed_place
      t.string   :place
      t.text     :description
      t.timestamps
    end
  end

  def self.down
    drop_table :date_schedules
  end
end
