require_dependency 'repositories_controller'

module IssueRepositoriesControllerPatch

    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            alias_method_chain :remove_related_issue, :full_id
        end
    end

    module InstanceMethods

        def remove_related_issue_with_full_id
            if params[:issue_id].include?('-')
                key, number = params[:issue_id].split('-')
                params[:issue_id] = Issue.find_legacy_id_by_project_key_and_issue_number(key, number)
            end
            remove_related_issue_without_full_id
        end

    end

end
