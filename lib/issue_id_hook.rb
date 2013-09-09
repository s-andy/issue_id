class IssueIdHook  < Redmine::Hook::ViewListener

    render_on :view_projects_form,                  :partial => 'projects/key'
    render_on :view_issues_sidebar_issues_bottom,   :partial => 'issues/title'
    render_on :view_issues_show_description_bottom, :partial => 'issues/id'

    # TODO view_issues_bulk_edit_details_bottom (replace ul with issue IDs)
end
