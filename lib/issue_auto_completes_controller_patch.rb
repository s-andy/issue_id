require_dependency 'auto_completes_controller'

module IssueAutoCompletesControllerPatch

    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            alias_method :issues, :issues_with_ids
        end
    end

    module InstanceMethods

        # A rework of #issues
        def issues_with_ids
            @issues = []
            q = (params[:q] || params[:term]).to_s.strip
            if q.present?
                if Issue.respond_to?(:cross_project_scope)
                    scope = Issue.cross_project_scope(@project, params[:scope]).visible
                else # Redmine < 3.x
                    scope = (params[:scope] == "all" || @project.nil? ? Issue : @project.issues).visible
                end
                if q.match(%r{\A#?([A-Z][A-Z0-9]*)-(\d+)\z})
                    @issues << scope.find_by_project_key_and_issue_number($1.upcase, $2.to_i)
                elsif q.match(%r{\A#?(\d+)\z})
                    @issues << scope.find_by_project_key_and_issue_number(@project.issue_key, $1.to_i) if @project
                    @issues << scope.find_by_id($1.to_i)
                end
                @issues += scope.where(["LOWER(#{Issue.table_name}.subject) LIKE LOWER(?)", "%#{q}%"])
                                .order("#{Issue.table_name}.id DESC")
                                .limit(10).to_a
                @issues.compact!
            end
            if Redmine::VERSION::MAJOR == 1
                render(:action => 'issues_old', :layout => false)
            else
                render(:layout => false)
            end
        end

    end

end
