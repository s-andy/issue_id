require_dependency 'issue'

module IssueIdPatch

    def self.included(base)
        base.class_eval do
            unloadable

            validates_uniqueness_of :issue_number, :scope => :project_key, :allow_blank => true
            validates_length_of :project_key, :in => 1..Project::ISSUE_KEY_MAX_LENGTH, :allow_blank => true
            validates_format_of :project_key, :with => %r{^[A-Z][A-Z0-9]*$}, :allow_blank => true
        end
    end

end
