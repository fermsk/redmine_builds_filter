module BuildsFilter
  module ProjectPatch
    def self.included(base)
      base.class_eval do
        has_many :builds, dependent: :destroy
      end
    end
  end
end

Project.include BuildsFilter::ProjectPatch