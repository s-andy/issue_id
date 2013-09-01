require 'redmine'

require_dependency 'issue_id_hook'

Rails.logger.info 'Starting ISSUE-id Plugin for Redmine'

# TODO
# rewrite issues/show issues/_list
# application_helper#link_to_issue

Rails.configuration.to_prepare do
    unless IssuesController.included_modules.include?(IssueIdsControllerPatch)
        IssuesController.send(:include, IssueIdsControllerPatch)
    end
    unless IssuesHelper.included_modules.include?(IssueIdsHelperPatch)
        IssuesHelper.send(:include, IssueIdsHelperPatch)
    end
    unless Project.included_modules.include?(IssueProjectPatch)
        Project.send(:include, IssueProjectPatch)
    end
end

Redmine::Plugin.register :issue_id do
    name 'ISSUE-id'
    author 'Andriy Lesyuk'
    author_url 'http://www.andriylesyuk.com/'
    description 'Adds support for issue ids in format: CODE-number.'
    url 'http://projects.andriylesyuk.com/projects/issue-id'
    version '0.0.1'

    settings :default => {
        :issue_key_sharing => false
    }, :partial => 'settings/issue_id'
end
