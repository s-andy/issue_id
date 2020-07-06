require_dependency 'application_helper'

module IssueApplicationHelperPatch

    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            alias_method :link_to_issue_without_id, :link_to_issue
            alias_method :link_to_issue, :link_to_issue_with_id
            alias_method :parse_redmine_links_without_issue_id, :parse_redmine_links
            alias_method :parse_redmine_links, :parse_redmine_links_with_issue_id
        end
    end

    module InstanceMethods

        def link_to_issue_with_id(issue, options = {})
            link = link_to_issue_without_id(issue, options)
            if issue.support_issue_id?
                link.gsub("##{issue.id}", "##{issue.to_param}").html_safe
            else
                link
            end
        end

        ISSUE_ID_RE = %r{([\s\(,\-\[\>]|\A)(!)?(#(?:([A-Z][A-Z0-9]*)-)?(\d+))((?:#note)?-(\d+))?(?=(?=[[:punct:]][^A-Za-z0-9_/])|,|\s|\]|<|\z)}m

        def parse_redmine_links_with_issue_id(text, project, obj, attr, only_path, options)
            text.gsub!(ISSUE_ID_RE) do |m|
                leading, esc, issue_text, key, number, note_text, note_id = $1, $2, $3, $4, $5, $6, $7
                link = nil
                if esc.nil?
                    if key.nil?
                        issue = Issue.visible.joins(:status).find_by_id(number.to_i)
                    else
                        issue = Issue.visible.joins(:status).find_by_project_key_and_issue_number(key.upcase, number.to_i)
                        unless issue
                            moved_issue = MovedIssue.find_by_old_key_and_old_number(key.upcase, number.to_i)
                            issue = moved_issue.issue if moved_issue && moved_issue.issue.visible?
                        end
                    end
                    if issue
                        anchor = note_id ? "note-#{note_id}" : nil
                        link = link_to("##{issue.to_param}", { :controller => 'issues', :action => 'show', :id => issue, :anchor => anchor, :only_path => only_path },
                                                               :class => issue.css_classes,
                                                               :title => "#{truncate(issue.subject, :length => 100)} (#{issue.status.name})")
                    end
                end
                leading + (link || "#{issue_text}#{note_text}")
            end

            parse_redmine_links_without_issue_id(text, project, obj, attr, only_path, options)
        end

    end

end
