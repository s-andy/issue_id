require_dependency 'issues_controller'

module IssueIdsControllerPatch

    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            prepend_before_filter :find_issue_by_id, :only => [ :show, :edit, :update ]
            # TODO find_issues _by_id
        end
    end

    module InstanceMethods

        def find_issue_by_id
            if params[:id].include?('-')
                parts = params[:id].split('-')
                if parts.size == 2
                    issue = Issue.find_by_project_key_and_issue_number(parts[0].upcase, parts[1])
                    params[:id] = issue.id if issue
                end
            end
        end

    end

end
