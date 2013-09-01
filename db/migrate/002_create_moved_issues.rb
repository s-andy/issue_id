class CreateMovedIssues < ActiveRecord::Migration

    def self.up
        create_table :moved_issues do |t|
            t.column :issue_id,   :integer
            t.column :old_key,    :string, :limit => 10
            t.column :old_number, :integer
        end

        add_index :moved_issues,   :old_number
        add_index :moved_issues, [ :old_key, :old_number ]
    end

    def self.down
        drop_table :moved_issues
    end

end
