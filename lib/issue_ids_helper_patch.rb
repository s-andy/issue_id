require_dependency 'issues_helper'

module IssueIdsHelperPatch

    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            alias_method_chain :issue_heading, :issue_id
        end
    end

    module InstanceMethods

        def issue_heading_with_issue_id(issue)
            if issue.project_key.present? && issue.issue_number.present?
                h("#{issue.tracker} ##{issue.project_key}-#{issue.issue_number}")
            else
                issue_heading_without_issue_id(issue)
            end
        end

    end

end
