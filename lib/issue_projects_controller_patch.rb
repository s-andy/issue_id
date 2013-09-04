require_dependency 'projects_controller'

module IssueProjectsControllerPatch

    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            after_filter :populate_subproject_keys, :only => [ :create, :update ]
        end
    end

    module InstanceMethods

        def populate_subproject_keys
            if @project.issue_key.present? && params[:share_issue_key] && flash[:notice] &&
                (flash[:notice] == l(:notice_successful_update) || flash[:notice] == l(:notice_successful_create))
                settings = Setting.plugin_issue_id
                if settings.is_a?(Hash) && settings[:issue_key_sharing]
                    @project.copy_issue_key_to_subprojects
                end
            end
        end

    end

end
