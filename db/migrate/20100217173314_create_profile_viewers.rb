class CreateProfileViewers < ActiveRecord::Migration
  def self.up
    create_table "profile_viewers" do |t|
      t.column :user_id,      :integer
      t.column :viewed_by,    :integer
      t.column :viewed_at,    :datetime
    end
  end

  def self.down
  end
end
