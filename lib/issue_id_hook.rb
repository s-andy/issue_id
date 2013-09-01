class IssueIdHook  < Redmine::Hook::ViewListener

    render_on :view_projects_form, :partial => 'projects/key'

end
