module BuildsFilter
  module IssuePatch
    def self.included(base)
      base.class_eval do
        belongs_to :build
        belongs_to :build_closed, class_name: 'Build'
        
        safe_attributes 'build_id', 'build_closed_id'

        def build_name
          build.try(:name)
        end

        def build_closed_name
          build_closed.try(:name)
        end
      end
    end
  end
end

Issue.include BuildsFilter::IssuePatch