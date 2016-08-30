if Rails::VERSION::MAJOR < 3

    ActionController::Routing::Routes.draw do |map|
        # Overrides
        map.quoted_issue('/issues/:id/quoted', :controller => 'journals', :action => 'new',
                                               :id => %r{(?:[A-Z0-9]+-)?[0-9]+}i, :conditions => { :method => :post })
    end

else

    # Overrides
    match '/issues/:id/quoted', :to => 'journals#new', :id => %r{(?:[A-Z0-9]+-)?[0-9]+}i, :via => :post, :as => 'issue_id_quoted_issue'

end
