require_dependency 'issues_controller'

module IssueIdsControllerPatch

    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            prepend_before_action :detect_moved_issues, :only => :show

            after_action :fix_creation_notice, :only => :create

            alias_method :build_new_issue_from_params_without_full_ids, :build_new_issue_from_params
            alias_method :build_new_issue_from_params, :build_new_issue_from_params_with_full_ids
            alias_method :retrieve_previous_and_next_issue_ids_without_full_ids, :retrieve_previous_and_next_issue_ids
            alias_method :retrieve_previous_and_next_issue_ids, :retrieve_previous_and_next_issue_ids_with_full_ids
        end
    end

    module InstanceMethods

        def detect_moved_issues
            if params[:id].include?('-')
                key, number = params[:id].split('-')
                moved_issue = MovedIssue.find_by_old_key_and_old_number(key.upcase, number.to_i)
                redirect_to(:controller => 'issues', :action => 'show', :id => moved_issue.issue, :status => :moved_permanently) if moved_issue
            end
        end

        def fix_creation_notice
            if @issue.support_issue_id? && flash[:notice] && flash[:notice] =~ %r{#[0-9]+}
                flash[:notice] = l(:notice_issue_successful_create, :id => "<a href=\"#{issue_path(@issue)}\">##{@issue.to_param}</a>")
            end
        end

        def build_new_issue_from_params_with_full_ids
            if params[:copy_from] && params[:copy_from].include?('-')
                key, number = params[:copy_from].split('-')
                params[:copy_from] = Issue.find_legacy_id_by_project_key_and_issue_number(key, number)
            end
            build_new_issue_from_params_without_full_ids
        end

        def retrieve_previous_and_next_issue_ids_with_full_ids
            retrieve_previous_and_next_issue_ids_without_full_ids
            if @prev_issue_id
                if @prev_issue_id.zero?
                    if params[:prev_issue_id] && params[:prev_issue_id].include?('-')
                        key, number = params[:prev_issue_id].split('-')
                        prev_issue  = Issue.find_by_project_key_and_issue_number(key, number)
                    end
                else
                    prev_issue = Issue.find_by_id(@prev_issue_id || params[:prev_issue_id])
                end
                @prev_issue_id = prev_issue.issue_id if prev_issue
            end
            if @next_issue_id
                if @next_issue_id.zero?
                    if params[:next_issue_id] && params[:next_issue_id].include?('-')
                        key, number = params[:next_issue_id].split('-')
                        next_issue  = Issue.find_by_project_key_and_issue_number(key, number)
                    end
                else
                    next_issue = Issue.find_by_id(@next_issue_id || params[:next_issue_id])
                end
                @next_issue_id = next_issue.issue_id if next_issue
            end
        end

    end

end
