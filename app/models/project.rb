class Project < ActiveRecord::Base
  include PublicActivity::Model
  attr_accessible :desc, :name, :is_department
  has_many :discussions, :dependent => :destroy
  has_many :tasks, :dependent => :destroy
  has_many :project_memberships, :dependent => :destroy
  has_many :sprints, :dependent => :destroy
  has_many :users, :through => :project_memberships

  validates :name, :presence => true, :length => {:minimum => 3}

  default_scope order(" created_at DESC")
  scope :without_departments, where(:is_department => false)
  scope :only_departments, where(:is_department => true)


  acts_as_paranoid
  acts_as_commentable

  #tracked owner: Proc.new{ |controller, model| controller.current_user }
  tracked(owner: Proc.new {|controller, model| controller.current_user }, recipient: Proc.new {|controller, model| model })



  # define project.admins, project.members ... methods
  ProjectMembership.role.values.each do |r|
    send(:define_method, r.underscore.pluralize) do
      self.project_memberships.where(:role => r.underscore).map(&:user)
    end
  end


  def project_manager
    #self.project_memberships.where(:project_id => project_id).first.role.text
    pm = nil
    project = self
    self.users.each do |u|
      if u.project_memberships.where(:project_id => project.id).first.role == "project_manager"
        pm = u
      end
    end
    pm
  end

  # status_via_words
  #a[0] = "estimate"
  #a[1] = "start"
  #a[2] = "finish"
  #a[3] = "pushed"
  #a[4] = "testing"
  #a[5] = "accept/reject"

  #type_via_words
  #a = []
  #a[0] = "feature"
  #a[1] = "bug"
  #a[2] = "chore"
  #a[3] = "instruction"
  #a[4] = "self_task"
  #a[5] = "easy_task"
  #a[6] = "story"


  def urgent
    self.tasks.where(:task_type => "3").order("end")
  end

  def draft
    self.tasks.where(:task_type => "5").order("finished_at").order("created_at DESC")
  end

  def current_work
    self.tasks.where("task_type != 5").where("status != 0").where("place != 1").order("status DESC")
  end
  #
  #def my_work user
  #  self.tasks.where(:assigned_to => user.id).where("task_type != 5").where("task_type != 3")
  #end

  def icebox
    self.tasks.where(:place => 0).where("task_type IN (0,1,2,6)")
    #.where("task_type != 5").where("task_type != 3")
  end

  def backlog
    self.tasks.where("task_type NOT IN (5,3,4,6)").where(:place => 1)
  end

end
