module BuildsFilter
  class Hooks < Redmine::Hook::ViewListener
    def view_issues_form_details_bottom(context = {})
      issue = context[:issue]
      form = context[:form]
      
      context[:controller].send(:render_to_string, {
        partial: 'issues/builds_form_fields', 
        locals: { issue: issue, form: form }
      })
    end

    def view_issues_show_details_bottom(context = {})
      issue = context[:issue]
      return unless issue.project && User.current.allowed_to?(:view_builds, issue.project)

      html = ''
      
      if issue.build
        html << "<div class='attribute'>"
        html << "<div class='label'>#{l(:field_build)}:</div>"
        html << "<div class='value'>#{h(issue.build.name)}</div>"
        html << "</div>"
      end

      if issue.build_closed
        html << "<div class='attribute'>"
        html << "<div class='label'>#{l(:field_build_closed)}:</div>"
        html << "<div class='value'>#{h(issue.build_closed.name)}</div>"
        html << "</div>"
      end

      html.html_safe
    end
  end
end