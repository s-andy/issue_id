# Overrides
match '/issues/:id/quoted', :to => 'journals#new', :id => %r{(?:[A-Z0-9]+-)?[0-9]+}i, :via => :post, :as => 'issue_id_quoted_issue'
