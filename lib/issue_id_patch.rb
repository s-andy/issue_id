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

            after_save :generate_issue_id

            alias_method_chain :to_s, :issue_id
        end
    end

    module ClassMethods

        def find(*args)
            if args.first && args.first.is_a?(String) && args.first.include?('-')
                key, number = args.shift.split('-')
                issue = find_by_project_key_and_issue_number(key.upcase, number.to_i, *args)
                raise ActiveRecord::RecordNotFound, "Couldn't find Issue with id=#{args.first}" unless issue
                issue
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

        def quoted_id
            issue_id.to_i.to_s
        end

        def to_s_with_issue_id
            if support_issue_id?
                "#{tracker} ##{to_param}: #{subject}"
            else
                to_s_without_issue_id
            end
        end

    private

        def generate_issue_id
            if project.issue_key.present?
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
