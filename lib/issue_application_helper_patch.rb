require_dependency 'application_helper'

module IssueApplicationHelperPatch

    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            alias_method_chain :link_to_issue, :id
        end
    end

    module InstanceMethods

        def link_to_issue_with_id(issue, options = {})
            link = link_to_issue_without_id(issue, options)
            if issue.support_issue_id?
                link.gsub("##{issue.id}", "##{issue.to_param}")
            else
                link
            end
        end

    end

end
