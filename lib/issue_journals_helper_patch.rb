require_dependency 'journals_helper'

module IssueJournalsHelperPatch

    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            alias_method :render_notes, :render_notes_with_issue_id
        end
    end

    module InstanceMethods

        # Largely a copy of #render_notes
        def render_notes_with_issue_id(issue, journal, options={})
            content = ''
            editable = User.current.logged? && (User.current.allowed_to?(:edit_issue_notes, issue.project) || (journal.user == User.current && User.current.allowed_to?(:edit_own_issue_notes, issue.project)))
            links = []
            if !journal.notes.blank?
                links << link_to(l(:button_quote),
                                 issue_id_quoted_issue_path(issue, :journal_id => journal),
                                 :remote => true,
                                 :method => 'post',
                                 :title  => l(:button_quote),
                                 :class  => 'icon-only icon-comment') if options[:reply_links]
                links << link_to(l(:button_edit),
                                 edit_journal_path(journal),
                                 :remote => true,
                                 :method => 'get',
                                 :title => l(:button_edit),
                                 :class => 'icon-only icon-edit') if editable
                links << link_to(l(:button_delete),
                                 journal_path(journal, :notes => ""),
                                 :remote => true,
                                 :method => 'put', :data => { :confirm => l(:text_are_you_sure) },
                                 :title => l(:button_delete),
                                 :class => 'icon-only icon-del') if editable
            end
            content << content_tag('div', links.join(' ').html_safe, :class => 'contextual') unless links.empty?
            content << textilizable(journal, :notes)
            css_classes = "wiki"
            css_classes << " editable" if editable
            content_tag('div', content.html_safe, :id => "journal-#{journal.id}-notes", :class => css_classes)
        end

    end

end
