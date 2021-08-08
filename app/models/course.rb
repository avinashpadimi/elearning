class Course < ApplicationRecord
  belongs_to :coach
  validates :name, :uniqueness => { :case_sensitive => false }, allow_blank: false
end
