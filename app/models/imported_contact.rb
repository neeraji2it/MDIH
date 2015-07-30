class ImportedContact < ActiveRecord::Base

  validates :email, :length => { :in => 6..250}, :presence => true
  validates :email, :format => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => 'email should look like an email address.' }
  
  belongs_to :user

  define_index do
    indexes name, :sortable => true
    indexes email, :sortable => true
    has user_id
  end
end
