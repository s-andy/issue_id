class AddIssuesProjectKeyAndNumber < Rails.version < '5.1' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]

    def self.up
        add_column :issues, :project_key,  :string, :limit => 10
        add_column :issues, :issue_number, :integer

        add_index :issues,   :issue_number
        add_index :issues, [ :project_key, :issue_number ]
    end

    def self.down
        remove_column :issues, :project_key
        remove_column :issues, :issue_number
    end

end
