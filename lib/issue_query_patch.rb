module IssueQueryPatch

    def self.included(base)
        base.send(:include, InstanceMethods) if base.name == 'Query'
        base.class_eval do
            unloadable

            if self.name == 'IssueQuery'
                id_column          = self.available_columns.detect{ |column| column.name == :id }
                id_column.name     = :issue_id
                id_column.sortable = [ "#{Issue.table_name}.project_key", "#{Issue.table_name}.issue_number", "#{Issue.table_name}.id" ]
            else
                alias_method_chain :sortable_columns, :issue_id
            end
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
