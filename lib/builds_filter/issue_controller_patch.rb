module BuildsFilter
  module IssueControllerPatch
    def self.included(base)
      base.class_eval do
        before_action :add_build_params_to_safe_attributes, only: [:create, :update]
        
        before_action :load_build_associations, only: [:show]

        private

        def add_build_params_to_safe_attributes
          if params[:issue]
            params[:issue][:safe_attributes] ||= {}
            params[:issue][:safe_attributes]['build_id'] = params[:issue][:build_id] if params[:issue][:build_id]
            params[:issue][:safe_attributes]['build_closed_id'] = params[:issue][:build_closed_id] if params[:issue][:build_closed_id]
          end
        end

        def load_build_associations
          @issue.build if @issue.build_id
          @issue.build_closed if @issue.build_closed_id
        end
      end
    end
  end
end