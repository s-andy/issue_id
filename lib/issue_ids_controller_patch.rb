require_dependency 'issues_controller'

module IssueIdsControllerPatch

    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            prepend_before_filter :detect_moved_issues, :only => :show

            after_filter :fix_creation_notice, :only => :create

            alias_method_chain :retrieve_previous_and_next_issue_ids, :full_ids
            # TODO bulk_update
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

        def retrieve_previous_and_next_issue_ids_with_full_ids
            retrieve_previous_and_next_issue_ids_without_full_ids
            if @prev_issue_id
                prev_issue = Issue.find_by_id(@prev_issue_id)
                @prev_issue_id = prev_issue.issue_id if prev_issue
            end
            if @next_issue_id
                next_issue = Issue.find_by_id(@next_issue_id)
                @next_issue_id = next_issue.issue_id if next_issue
            end
        end

    end

end
