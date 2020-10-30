require_dependency 'journals_helper'

module IssueJournalsHelperPatch

    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            alias_method :render_journal_actions, :render_journal_actions_with_issue_id
        end
    end

    module InstanceMethods

        def render_journal_actions_with_issue_id(issue, journal, options={})
            links = []
            if journal.notes.present?
              if options[:reply_links]
                indice = journal.indice || @journal.issue.visible_journals_with_index.find{|j| j.id == @journal.id}.indice
                links << link_to(l(:button_quote),
                                 issue_id_quoted_issue_path(issue, :journal_id => journal, :journal_indice => indice),
                                 :remote => true,
                                 :method => 'post',
                                 :title => l(:button_quote),
                                 :class => 'icon-only icon-comment'
                                )
              end
              if journal.editable_by?(User.current)
                links << link_to(l(:button_edit),
                                 edit_journal_path(journal),
                                 :remote => true,
                                 :method => 'get',
                                 :title => l(:button_edit),
                                 :class => 'icon-only icon-edit'
                                )
                links << link_to(l(:button_delete),
                                 journal_path(journal, :journal => {:notes => ""}),
                                 :remote => true,
                                 :method => 'put', :data => {:confirm => l(:text_are_you_sure)},
                                 :title => l(:button_delete),
                                 :class => 'icon-only icon-del'
                                )
              end
            end
            safe_join(links, ' ')
        end

    end

end
