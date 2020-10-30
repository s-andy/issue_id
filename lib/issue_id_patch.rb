require_dependency 'issue'


module IssueIdPatch

    def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            validates_uniqueness_of :issue_number, :scope => :project_key, :allow_blank => true, :if => Proc.new { |issue| issue.issue_number_changed? }
            validates_length_of :project_key, :in => 1..Project::ISSUE_KEY_MAX_LENGTH, :allow_blank => true
            validates_format_of :project_key, :with => %r{\A#{IssueID::FORMAT}\z}, :allow_blank => true

            after_save :create_moved_issue, :generate_issue_id, :send_notification_with_full_id

            alias_method :to_s_without_issue_id, :to_s
            alias_method :to_s, :to_s_with_issue_id

            alias_method :safe_attributes_without_issue_id=, :safe_attributes=
            alias_method :safe_attributes=, :safe_attributes_with_issue_id=
            alias_method :parent_issue_id_without_full_id=, :parent_issue_id=
            alias_method :parent_issue_id=, :parent_issue_id_with_full_id=
            alias_method :parent_issue_id_without_full_id, :parent_issue_id
            alias_method :parent_issue_id, :parent_issue_id_with_full_id
            alias_method :copy_from_without_issue_id, :copy_from
            alias_method :copy_from, :copy_from_with_issue_id
            alias_method :send_notification_without_delay, :send_notification
            alias_method :send_notification, :send_notification_with_delay
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

        def find_by_id(id)
            if id.is_a?(String) && id.include?('-')
                key, number = id.split('-')
                find_by_project_key_and_issue_number(key.upcase, number.to_i)
            else
                find_by(:id => id)
            end
        end

        def where(*args)
            if args.first && args.first.is_a?(Hash) && args.first.key?(:id)
                if args.first[:id].is_a?(Array) && args.first[:id].count == 1
                    issue_id = args.first[:id].first
                else
                    issue_id = args.first[:id]
                end
                if issue_id.is_a?(String) && issue_id.include?('-')
                    key, number = issue_id.split('-')

                    args.first[:project_key]  = key.upcase
                    args.first[:issue_number] = number.to_i
                    args.first.delete(:id)
                end
            end
            super
        end

        def find_legacy_id_by_project_key_and_issue_number(key, number)
            issue = find_by_project_key_and_issue_number(key.upcase, number.to_i)
            return issue.id if issue

            moved_issue = MovedIssue.find_by_old_key_and_old_number(key.upcase, number.to_i)
            return moved_issue.issue.id if moved_issue
        end

    end

    module InstanceMethods

        def safe_attributes_with_issue_id=(attrs, user = User.current)
            if attrs['parent_issue_id'].present? &&
            attrs['parent_issue_id'].is_a?(String) && attrs['parent_issue_id'].include?('-')
                key, number = attrs['parent_issue_id'].split('-')

                legacy_id = self.class.find_legacy_id_by_project_key_and_issue_number(key.gsub(%r{^#}, ''), number)
                attrs['parent_issue_id'] = legacy_id if legacy_id
            end

            send(:safe_attributes_without_issue_id=, attrs, user)
        end

        def parent_issue_id_with_full_id=(arg)
            if arg.is_a?(String) && arg.include?('-')
                key, number = arg.strip.split('-')

                legacy_id = self.class.find_legacy_id_by_project_key_and_issue_number(key.gsub(%r{^#}, ''), number)
                arg = legacy_id if legacy_id
            end

            send(:parent_issue_id_without_full_id=, arg)
        end

        def parent_issue_id_with_full_id
            if instance_variable_defined?(:@parent_issue)
                @parent_issue.nil? ? nil : @parent_issue.issue_id
            else
                parent_issue_id_without_full_id
            end
        end

        def copy_from_with_issue_id(arg, options={})
            result = copy_from_without_issue_id(arg, options)

            self.project_key  = nil
            self.issue_number = nil

            result
        end

        def send_notification_with_delay
            @delayed_notification = true
        end

        def send_notification_with_full_id
            send_notification_without_delay if @delayed_notification
        end

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
                    Issue.where(:id => id)
                        .update_all(:project_key  => project.issue_key,
                                    :issue_number => reserved_number)
                    reload
                end
            end
        end

    end

end
