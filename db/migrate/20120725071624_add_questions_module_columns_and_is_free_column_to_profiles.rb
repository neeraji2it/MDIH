class AddQuestionsModuleColumnsAndIsFreeColumnToProfiles < ActiveRecord::Migration
  def change
    add_column  :profiles, :is_free, :boolean, :default => false
    add_column  :profiles, :who_am_i, :text
    add_column  :profiles, :what_is_my_passion, :text
    add_column  :profiles, :when_i_am_not_working_i, :text
    add_column  :profiles, :cannot_live_without, :text
  end
end
