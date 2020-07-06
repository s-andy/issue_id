require_dependency 'issue_relations_controller'

module IssueIdsRelationsControllerPatch

    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            before_action :prepare_issue_to_id, :only => :create
        end
    end

    module InstanceMethods

        def prepare_issue_to_id
            if params[:relation] && m = params[:relation][:issue_to_id].to_s.strip.match(%r{\A#?([A-Z][A-Z0-9]*-[0-9]+)\z})
                begin
                    issue_to = Issue.find(m[1])
                    params[:relation][:issue_to_id] = issue_to.id
                rescue ActiveRecord::RecordNotFound
                end
            end
        end

    end

end
