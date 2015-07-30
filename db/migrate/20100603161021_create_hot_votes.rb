class CreateHotVotes < ActiveRecord::Migration
  def self.up
    create_table :hot_votes do |t|
      t.integer :user_id
      t.integer :hoter_id
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :hot_votes
  end
end
