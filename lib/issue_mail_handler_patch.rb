require_dependency 'mail_handler'

module IssueMailHandlerPatch

    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            alias_method :dispatch_without_issue_id, :dispatch
            alias_method :dispatch, :dispatch_with_issue_id
        end
    end

    module InstanceMethods

        ISSUE_ID_REPLY_SUBJECT_RE = %r{\[(?:[^\]]*\s+)?#(#{IssueID::FORMAT})-(\d+)\]}

        def dispatch_with_issue_id
            subject = email.subject.to_s
            if m = subject.match(ISSUE_ID_REPLY_SUBJECT_RE)
                receive_issue_reply(Issue.find_legacy_id_by_project_key_and_issue_number(m[1].upcase, m[2].to_i))
            else
                dispatch_without_issue_id
            end
        end

    end

end
