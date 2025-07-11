class Build < ActiveRecord::Base
  include Redmine::SafeAttributes

  belongs_to :project
  has_many :issues
  has_many :closed_issues, class_name: 'Issue', foreign_key: 'build_closed_id'

  validates :name, presence: true, uniqueness: { scope: :project_id }
  validates :project, presence: true

  scope :sorted, -> { order(created_at: :desc) }

  safe_attributes 'name', 'project_id'

  def to_s
    "#{name} (#{project.name})"
  end

  def name_with_project
    "#{name} (#{project.name})"
  end
end