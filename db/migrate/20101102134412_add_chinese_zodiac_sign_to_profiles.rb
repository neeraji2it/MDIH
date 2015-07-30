class AddChineseZodiacSignToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :chinese_zodiac_sign, :string, :limit => 16
  end

  def self.down
    remove :profiles, :chinese_zodiac_sign
  end
end
