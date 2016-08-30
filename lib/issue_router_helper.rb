module IssueRouterHelper

    def quoted_issue_path(issue, options = {})
        issue_id_quoted_issue_path(issue, options)
    end

    def quoted_issue_url(issue, options = {})
        issue_id_quoted_issue_url(issue, options)
    end

end
