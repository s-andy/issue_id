class AddProjectsIssueKey < ActiveRecord::Migration

    def self.up
        add_column :projects, :issue_key, :string, :limit => 10
    end

    def self.down
        remove_column :projects, :issue_key
    end

end
