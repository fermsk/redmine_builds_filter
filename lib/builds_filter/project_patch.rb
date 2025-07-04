module BuildsFilter
  module ProjectPatch
    def self.included(base)
      base.class_eval do
        has_many :builds, dependent: :destroy
        
        def all_builds
          Build.where(project_id: self_and_ancestors.map(&:id))
        end
      end
    end
  end
end

Project.include BuildsFilter::ProjectPatch