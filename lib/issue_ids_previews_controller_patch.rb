require_dependency 'previews_controller'

module IssueIdsPreviewsControllerPatch

    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            before_action :prepare_issue_id, :only => :issue
        end
    end

    module InstanceMethods

        def prepare_issue_id
            if params[:id] && m = params[:id].to_s.match(%r{\A#?(#{IssueID::FORMAT}-[0-9]+)\z})
                begin
                    issue = Issue.find(m[1])
                    params[:id] = issue.id
                rescue ActiveRecord::RecordNotFound
                end
            end
        end

    end

end
