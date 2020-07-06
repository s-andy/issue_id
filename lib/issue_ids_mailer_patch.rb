require_dependency 'mailer'

module IssueIdsMailerPatch

    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            alias_method :issue_add_without_full_id, :issue_add
            alias_method :issue_add, :issue_add_with_full_id
            alias_method :issue_edit_without_full_id, :issue_edit
            alias_method :issue_edit, :issue_edit_with_full_id
        end
    end

    module InstanceMethods

        def issue_add_with_full_id(issue, to_users, cc_users)
            message = issue_add_without_full_id(issue, to_users, cc_users)
            message.subject = replace_with_full_id(message.subject) if @issue.support_issue_id?
            message
        end

        def issue_edit_with_full_id(journal, to_users, cc_users)
            message = issue_edit_without_full_id(journal, to_users, cc_users)
            message.subject = replace_with_full_id(message.subject) if @issue.support_issue_id?
            message
        end
        
    private

        def replace_with_full_id(subject)
            subject.gsub(%r{##{@issue.id}\b}, "##{@issue.to_param}")
        end

    end

end
