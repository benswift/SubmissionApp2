class Group < ActiveRecord::Base
  belongs_to :course
  has_many :users
  has_many :students
  has_and_belongs_to_many :convenors
  belongs_to :user
  belongs_to :tutor
  
  def get_student_roles
    course_id = self.course.id.to_s
    (self.students + User.all.select{|u| u.role.to_h[course_id] == "Student" && u.groups.include?(self)}).uniq
  end
end
