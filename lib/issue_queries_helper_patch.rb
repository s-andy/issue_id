require_dependency 'queries_helper'

module IssueQueriesHelperPatch

    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            alias_method :column_value_without_issue_id, :column_value
            alias_method :column_value, :column_value_with_issue_id
        end
    end

    module InstanceMethods

        def column_value_with_issue_id(column, issue, value)
            if column.name == :issue_id || column.name == :legacy_id
                link_to(value, issue_path(issue))
            else
                column_value_without_issue_id(column, issue, value)
            end
        end

    end

end
