require_dependency 'changeset'

module IssueChangesetPatch

    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            alias_method_chain :scan_comment_for_issue_ids, :full_ids
        end
    end

    module InstanceMethods

        ISSUE_ID_RE = %r{[A-Z][A-Z0-9]*-\d+}

        # Almost a copy of find_referenced_issue_by_id
        def find_referenced_issue_by_full_id(id)
            return nil if id.blank?
            return nil unless id.include?('-')
            key, number = id.split('-')
            issue = Issue.find_by_project_key_and_issue_number(key.upcase, number.to_i, :include => :project)
            unless issue
                moved_issue = MovedIssue.find_by_old_key_and_old_number(key.upcase, number.to_i)
                issue = moved_issue.issue if moved_issue
            end
            return issue if Setting.commit_cross_project_ref?
            if issue
                retur nil unless issue.project &&
                                (project == issue.project || project.is_ancestor_of?(issue.project) ||
                                 project.is_descendant_of?(issue.project))
            end
            issue
        end

        # Almost a copy of scan_comment_for_issue_ids
        def scan_comment_for_full_ids
            return if comments.blank?
            ref_keywords      = Setting.commit_ref_keywords.downcase.split(',').collect(&:strip)
            ref_keywords_any  = ref_keywords.delete('*')
            fix_keywords      = Setting.commit_fix_keywords.downcase.split(',').collect(&:strip)
            kw_regexp         = (ref_keywords + fix_keywords).collect{ |kw| Regexp.escape(kw) }.join('|')
            referenced_issues = []

            comments.scan(/([\s\(\[,-]|^)((#{kw_regexp})[\s:]+)?(##{ISSUE_ID_RE}(\s+@#{Changeset::TIMELOG_RE})?([\s,;&]+##{ISSUE_ID_RE}(\s+@#{Changeset::TIMELOG_RE})?)*)(?=[[:punct:]]|\s|<|$)/i) do |match|
                action, refs = match[2], match[3]
                next unless action.present? || ref_keywords_any
                refs.scan(/#(#{ISSUE_ID_RE})(\s+@#{Changeset::TIMELOG_RE})?/).each do |m|
                    issue, hours = find_referenced_issue_by_full_id(m[0]), m[2]
                    if issue
                        referenced_issues << issue
                        fix_issue(issue) if fix_keywords.include?(action.to_s.downcase)
                        log_time(issue, hours) if hours && Setting.commit_logtime_enabled?
                    end
                end
            end

            unless referenced_issues.empty?
                referenced_issues.push(self.issues) unless self.issues.empty?
                referenced_issues.uniq!
                self.issues = referenced_issues
            end
        end

        def scan_comment_for_issue_ids_with_full_ids
            scan_comment_for_issue_ids_without_full_ids
            scan_comment_for_full_ids
        end

    end

end
