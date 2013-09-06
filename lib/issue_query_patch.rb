require_dependency 'query'

module IssueQueryPatch

    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            alias_method_chain :sortable_columns, :issue_id
        end
    end

    module InstanceMethods

        def sortable_columns_with_issue_id
            columns = sortable_columns_without_issue_id
            columns['id'] = [ "#{Issue.table_name}.project_key", "#{Issue.table_name}.issue_number", "#{Issue.table_name}.id" ]
            columns
        end

    end

end
