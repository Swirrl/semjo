class Blog < CouchRest::Model::Base
  
  # central db  
  use_database CouchRest::Database.new(CouchRest::Server.new(APP_CONFIG['couch_db_location']), "semanticjournal")

  property :home_path, :default => "/articles"
  property :name
  property :hosts
  property :html5, TrueClass, :default => false
  property :articles_per_page, :default => 8

  view_by :name 

  # proxy all the db-specific models.
  proxy_for :articles
  proxy_for :pages
  proxy_for :blog_users
  
  def proxy_database
    @proxy_database ||= CouchRest::Database.new(CouchRest::Server.new(APP_CONFIG['couch_db_location']), self.name)
  end

  design do 
    # call with :key => 'host' to get all the blogs that use that host (should only really be 1)
    # call with :key => 'host' and :reduce => true to see how many times a tag has been used
    # call with :group => true and :reduce => true to get all of the unique hosts that exist in the system.  
    view :by_hosts, 
      :map => 
        "function(doc) {
          if (doc['couchrest-type'] == 'Blog' && doc.hosts) {
            doc.hosts.forEach(function(host){
              emit(host, 1);
            });
          }
        }",
       :reduce =>
          "function(keys, values, rereduce) {
            return sum(values);
          }"
  end
      
  def canonical_url
    if hosts && hosts.length > 0
      return hosts[0]
    else
      raise RuntimeError.new("no hosts for blog")
    end
  end
   
end
