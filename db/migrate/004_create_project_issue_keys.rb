class CreateProjectIssueKeys < ActiveRecord::Migration

    def self.up
        create_table :project_issue_keys do |t|
            t.column :project_key,       :string,  :limit => 10,  :null => false
            t.column :last_issue_number, :integer, :default => 0, :null => false
        end
        add_index :project_issue_keys, :project_key
    end

    def self.down
        drop_table :project_issue_keys
    end

end
