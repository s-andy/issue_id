class ProjectIssueKey < ActiveRecord::Base
    include Redmine::SafeAttributes

    has_many :projects, :primary_key => :project_key, :foreign_key => :issue_key

    validates_presence_of :project_key
    validates_uniqueness_of :project_key
    validates_length_of :project_key, :in => 1..Project::ISSUE_KEY_MAX_LENGTH
    validates_format_of :project_key, :with => %r{\A[A-Z][A-Z0-9]*\z}, :if => Proc.new { |key| key.project_key_changed? }

    safe_attributes 'project_key'

    def reserve_issue_number!
        issue_number = 0
        self.class.transaction do
            reload(:lock => true)
            if increment!(:last_issue_number)
                issue_number = last_issue_number
            else
                raise ActiveRecord::Rollback
            end
        end
        issue_number
    end

    def self.reserve_issue_number!(key)
        issue_number = 0
        transaction do
            project_issue_key = lock(true).find_by_project_key(key)
            unless project_issue_key
                project_issue_key = new(:project_key => key)
                project_issue_key.save!
            end
            if project_issue_key.increment!(:last_issue_number)
                issue_number = project_issue_key.last_issue_number
            else
                raise ActiveRecord::Rollback
            end
        end
        issue_number
    end

end
