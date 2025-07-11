module BuildsFilter
  module ProjectPatch
    def self.included(base)
      base.class_eval do
        has_many :builds, -> { order(created_at: :desc) }, dependent: :destroy
        
        def all_builds
          Build.where(project_id: self_and_ancestors.map(&:id)).order(created_at: :desc)
        end
      end
    end
  end
end

Project.include BuildsFilter::ProjectPatch