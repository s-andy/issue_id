require_dependency 'application_controller'

module IssueApplicationControllerPatch

    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            alias_method_chain :find_issues, :full_ids
        end
    end

    module InstanceMethods

        def find_issues_with_full_ids
            if params[:id] && params[:id].include?('-')
                key, number = params[:id].split('-')
                params[:id] = Issue.find_legacy_id_by_project_key_and_issue_number(key, number)
            end
            find_issues_without_full_ids
        end

    end

end
