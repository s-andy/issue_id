class IssueIdHook  < Redmine::Hook::ViewListener

    render_on :view_projects_form,                :partial => 'projects/key'
    render_on :view_issues_sidebar_issues_bottom, :partial => 'issues/title'

end
