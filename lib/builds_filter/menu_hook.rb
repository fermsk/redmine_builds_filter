module BuildsFilter
  class MenuHook < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(context={})
      stylesheet_link_tag('builds_filter', :plugin => 'builds_filter') +
      javascript_include_tag('builds_select', :plugin => 'builds_filter')
    end
  end
end