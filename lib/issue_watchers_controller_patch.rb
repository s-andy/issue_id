require_dependency 'watchers_controller'

module IssueWatchersControllerPatch

    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            alias_method_chain :find_objets_from_params, :full_ids
        end
    end

    module InstanceMethods

        def find_objets_from_params_with_full_ids
            if params[:object_id].is_a?(String) && params[:object_id].include?('-')
                key, number = params[:object_id].split('-')
                params[:object_id] = Issue.find_legacy_id_by_project_key_and_issue_number(key, number)
            end
            find_objets_from_params_without_full_ids
        end

    end

end
