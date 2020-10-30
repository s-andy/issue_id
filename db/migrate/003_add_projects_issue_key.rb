class AddProjectsIssueKey < Rails.version < '5.1' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]

    def self.up
        add_column :projects, :issue_key, :string, :limit => 10
    end

    def self.down
        remove_column :projects, :issue_key
    end

end
