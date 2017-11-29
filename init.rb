require 'redmine'

require_dependency 'issue_id_hook'

Rails.logger.info 'Starting ISSUE-id Plugin for Redmine'

issue_query = (IssueQuery rescue Query)

issue_query.add_available_column(QueryColumn.new(:legacy_id,
                                                 :sortable => "#{Issue.table_name}.id",
                                                 :caption => :label_legacy_id))

Rails.configuration.to_prepare do
    unless Rails.application.routes.url_helpers.included_modules.include?(IssueRouterHelper)
        Rails.application.routes.url_helpers.send(:include, IssueRouterHelper)
    end
    unless ApplicationHelper.included_modules.include?(IssueApplicationHelperPatch)
        ApplicationHelper.send(:include, IssueApplicationHelperPatch)
    end
    unless IssuesController.included_modules.include?(IssueIdsControllerPatch)
        IssuesController.send(:include, IssueIdsControllerPatch)
    end
    unless IssueRelationsController.included_modules.include?(IssueIdsRelationsControllerPatch)
        IssueRelationsController.send(:include, IssueIdsRelationsControllerPatch)
    end
    unless PreviewsController.included_modules.include?(IssueIdsPreviewsControllerPatch)
        PreviewsController.send(:include, IssueIdsPreviewsControllerPatch)
    end
    unless AutoCompletesController.included_modules.include?(IssueAutoCompletesControllerPatch)
        AutoCompletesController.send(:include, IssueAutoCompletesControllerPatch)
    end
    unless IssuesHelper.included_modules.include?(IssueIdsHelperPatch)
        IssuesHelper.send(:include, IssueIdsHelperPatch)
    end
    unless Redmine::VERSION::MAJOR < 3 || (Redmine::VERSION::MAJOR == 3 && Redmine::VERSION::MINOR == 0)
        unless JournalsHelper.included_modules.include?(IssueJournalsHelperPatch)
            JournalsHelper.send(:include, IssueJournalsHelperPatch)
        end
    end
    if defined?(IssueQuery)
        unless QueriesHelper.included_modules.include?(IssueQueriesHelperPatch)
            QueriesHelper.send(:include, IssueQueriesHelperPatch)
        end
        unless IssueQuery.included_modules.include?(IssueQueryPatch)
            IssueQuery.send(:include, IssueQueryPatch)
        end
    else
        unless Query.included_modules.include?(IssueQueryPatch)
            Query.send(:include, IssueQueryPatch)
        end
    end
    unless Project.included_modules.include?(IssueProjectPatch)
        Project.send(:include, IssueProjectPatch)
    end
    unless Issue.included_modules.include?(IssueIdPatch)
        Issue.send(:include, IssueIdPatch)
    end
    unless Changeset.included_modules.include?(IssueChangesetPatch)
        Changeset.send(:include, IssueChangesetPatch)
    end

    Issue.event_options[:title] = Proc.new do |issue|
        "#{issue.tracker.name} ##{issue.to_param} (#{issue.status}): #{issue.subject}"
    end
    Issue.event_options[:url] = Proc.new do |issue|
        { :controller => 'issues', :action => 'show', :id => issue }
    end

    Journal.event_options[:title] = Proc.new do |journal|
        status = ((new_status = journal.new_status) ? " (#{new_status})" : nil)
        "#{journal.issue.tracker} ##{journal.issue.to_param}#{status}: #{journal.issue.subject}"
    end
    Journal.event_options[:url] = Proc.new do |journal|
        { :controller => 'issues', :action => 'show', :id => journal.issue, :anchor => "change-#{journal.id}" }
    end
end

Redmine::Plugin.register :issue_id do
    name 'ISSUE-id'
    author 'Andriy Lesyuk'
    author_url 'http://www.andriylesyuk.com/'
    description 'Adds support for issue ids in format: CODE-number.'
    url 'http://projects.andriylesyuk.com/projects/issue-id'
    version '0.0.1b'

    settings :default => {
        :issue_key_sharing => false
    }, :partial => 'settings/issue_id'
end
