class Assignment < ActiveRecord::Base
  belongs_to :course
  has_many :submissions
  has_many :users
end
