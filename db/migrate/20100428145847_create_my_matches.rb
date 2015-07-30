class CreateMyMatches < ActiveRecord::Migration
  def self.up
    create_table :my_matches do |t|
      t.integer :user_id
      t.integer :matcher_id
      t.integer :match_percent
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :my_matches
  end
end
