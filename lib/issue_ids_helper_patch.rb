require_dependency 'issues_helper'

module IssueIdsHelperPatch

    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            alias_method :issue_heading_without_full_id, :issue_heading
            alias_method :issue_heading, :issue_heading_with_full_id
        end
    end

    module InstanceMethods

        def issue_heading_with_full_id(issue)
            if issue.project_key.present? && issue.issue_number.present?
                h("#{issue.tracker} ##{issue.to_param}")
            else
                issue_heading_without_full_id(issue)
            end
        end

    end

end
