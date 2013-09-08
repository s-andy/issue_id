require_dependency 'issue'

module IssueIdPatch

    def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            validates_uniqueness_of :issue_number, :scope => :project_key, :allow_blank => true, :if => Proc.new { |issue| issue.issue_number_changed? }
            validates_length_of :project_key, :in => 1..Project::ISSUE_KEY_MAX_LENGTH, :allow_blank => true
            validates_format_of :project_key, :with => %r{^[A-Z][A-Z0-9]*$}, :allow_blank => true

            after_save :create_moved_issue, :generate_issue_id

            alias_method_chain :to_s, :issue_id
        end
    end

    module ClassMethods

        def find(*args)
            if args.first && args.first.is_a?(String) && args.first.include?('-')
                key, number = args.shift.split('-')

                issue = find_by_project_key_and_issue_number(key.upcase, number.to_i, *args)
                return issue if issue

                moved_issue = MovedIssue.find_by_old_key_and_old_number(key.upcase, number.to_i)
                if moved_issue
                    issue = find_by_id(moved_issue.issue.id.to_i, *args)
                    return issue if issue
                end

                raise ActiveRecord::RecordNotFound, "Couldn't find Issue with id=#{args.first}"
            else
                super
            end
        end

    end

    module InstanceMethods

        def support_issue_id?
            project_key.present? && issue_number.present?
        end

        def issue_id
            if support_issue_id?
                @issue_id ||= IssueID.new(id, project_key, issue_number)
            else
                id
            end
        end

        def to_param
            issue_id.to_param
        end

        def legacy_id
            id
        end

        def to_s_with_issue_id
            if support_issue_id?
                "#{tracker} ##{to_param}: #{subject}"
            else
                to_s_without_issue_id
            end
        end

    private

        def create_moved_issue
            if support_issue_id? && project.issue_key != project_key
                moved_issue = MovedIssue.new(:issue => self, :old_key => project_key, :old_number => issue_number)
                moved_issue.save

                # to let generate_issue_id do its job
                self.project_key  = nil
                self.issue_number = nil
            end
        end

        def generate_issue_id
            if !support_issue_id? && project.issue_key.present?
                reserved_number = ProjectIssueKey.reserve_issue_number!(project.issue_key)
                if reserved_number
                    Issue.update_all({ :project_key => project.issue_key,
                                       :issue_number => reserved_number }, :id => id)
                    reload
                end
            end
        end

    end

end
