class Build < ActiveRecord::Base
  include Redmine::SafeAttributes

  belongs_to :project
  has_many :issues
  has_many :closed_issues, class_name: 'Issue', foreign_key: 'build_closed_id'

  validates :name, presence: true, uniqueness: { scope: :project_id }

  scope :sorted, -> { order(:name) }

  safe_attributes 'name', 'project_id',
    if: lambda {|build, user| user.allowed_to?(:edit_builds, build.project) }

  def to_s
    "#{name} (#{project.name})"
  end

  def name_with_project
    "#{name} (#{project.name})"
  end
end