require 'redmine'

Redmine::Plugin.register :builds_filter do
  name 'Builds Filter plugin'
  author 'Ivan Zheleznyi'
  description 'This plugin adds build and build_closed filters to issues and a Builds menu item'
  version '0.0.3'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  requires_redmine version_or_higher: '4.0'

  project_module :builds do
    permission :view_builds, { builds: [:index, :show, :auto_complete] }
    permission :create_builds, { builds: [:new, :create] }
    permission :edit_builds, { builds: [:edit, :update] }
    permission :delete_builds, { builds: [:destroy] }
  end

  menu :project_menu, :builds,
       { controller: 'builds', action: 'index' },
       caption: :label_builds,
       param: :project_id,
       after: :activity
  end

Rails.application.config.to_prepare do
  require_dependency 'issue'
  require_dependency 'issue_query'
  require_dependency 'project'

  path = File.expand_path('../lib/builds_filter', __FILE__)

  require_dependency "#{path}/issue_patch"
  require_dependency "#{path}/issue_query_patch"
  require_dependency "#{path}/project_patch"
  require_dependency "#{path}/hooks"
  require_dependency 'issues_controller'
  require_dependency "#{path}/issue_controller_patch"


  unless IssueQuery.included_modules.include?(BuildsFilter::IssueQueryPatch)
    IssueQuery.prepend(BuildsFilter::IssueQueryPatch)
  end

  unless Issue.included_modules.include?(BuildsFilter::IssuePatch)
    Issue.prepend(BuildsFilter::IssuePatch)
  end

  unless Project.included_modules.include?(BuildsFilter::ProjectPatch)
    Project.include(BuildsFilter::ProjectPatch)
  end
  
  unless IssuesController.included_modules.include?(BuildsFilter::IssueControllerPatch)
    IssuesController.send(:include, BuildsFilter::IssueControllerPatch)
  end
end