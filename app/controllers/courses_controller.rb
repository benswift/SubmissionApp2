class CoursesController < ApplicationController
  before_filter :require_logged_in, :except => [:index]

  def new
  end

  def create

    course_code = params[:course_code]
    course_name = params[:name]
    description = params[:description]
    students    = params[:students].split(/\n/).reject(&:empty?)
    tutors      = params[:tutors].split(/\n/).reject(&:empty?)
    convenors   = params[:convenors].split(/\n/).reject(&:empty?)

    # Create the course
    c = Course.create(
      :code => course_code,
      :name => course_name,
      :description => description)

    # Enrol staff and students
    if current_user.is_convenor?
      c.convenors << current_user
    end

    if not students.empty?
      counter = 0
      students.each do |s|
        # Remove spaces
        s.gsub!(/\s+/, "")

        if Student.find_by_uid(s)
          c.students << Student.find_by_uid(s)
        else
          # Look up student details
          ldap_user = AnuLdap.find_by_uni_id(s)
          if ldap_user
            s = Student.create(:uid => s, :firstname => ldap_user.given_name, :surname => ldap_user.surname)
            c.students << s
            counter += 1
          else
            flash_message :error, "The student <#{s}> could not be found on the LDAP server."
          end
        end
      end
      flash_message :success, "Sucessfully enrolled #{counter} students."
    end

    if not tutors.empty?
      counter = 0
      tutors.each do |t|
        # Remove spaces
        t.gsub!(/\s+/, "")

        if Tutor.find_by_uid(t)
          c.tutors << Tutor.find_by_uid(t)
        else
          # Look up user details
          ldap_user = AnuLdap.find_by_uni_id(t)
          if ldap_user
            t = Tutor.create(:uid => t, :firstname => ldap_user.given_name, :surname => ldap_user.surname)
            c.tutor << t
            counter += 1
          else
            flash_message :error, "The tutor <#{t}> could not be found on the LDAP server."
          end
        end
      end
      flash_message :success, "Sucessfully enrolled #{counter} tutors."
    end

    if not convenors.empty?
      counter = 0
      convenors.each do |conv|
        # Remove spaces
        s.gsub!(/\s+/, "")

        if Convenor.find_by_uid(conv)
          c.convenors << Convenor.find_by_uid(conv)
        else
          # Look up user details
          ldap_user = AnuLdap.find_by_uni_id(conv)
          if ldap_user
            conv = Convenor.create(:uid => conv, :firstname => ldap_user.given_name, :surname => ldap_user.surname)
            c.convenors << conv
            counter += 1
          else
            flash_message :error, "The convenor <#{conv}> could not be found on the LDAP server."
          end
        end
      end
      flash_message :success, "Sucessfully enrolled #{counter} students."
    end

    redirect_to '/courses'

  end

  def edit
  end

  def show
    if params[:id] && Course.find_by_id(params[:id])
      @course = Course.find_by_id(params[:id])
    else
      flash_message :error, "Could not find a course with ID=" + params[:id].to_s
      redirect_to "/"
    end
  end

  def index
    if current_user
      if current_user.is_admin?
        @courses = Course.all
      else
        @courses = current_user.courses
      end
    else
      redirect_to "/"
    end
  end

  def destroy
  end
end