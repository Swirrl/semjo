# a user for a particular blog.  
class BlogUser < CouchRest::Model::Base
  
  #extend SemanticJournalCouchRest::DatabaseFromThread

  property :account #gives us a link to the account doc.

  timestamps! #force writing of updated_at and created_at
  
  proxied_by :blog
  
  design do
    view :by_account
  end
  
end