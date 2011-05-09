namespace :couchdb do

  # refresh all the design docs on the server
  # e.g. rake refresh_design_docs SERVER="http://127.0.0.1:5984"
  task (:refresh_design_docs => :environment) do
    
    server_location = ENV['SERVER']
    
    svr = CouchRest::Server.new(server_location)
      
    svr.databases.each do |db_name|
      ENV['DATABASE'] = db_name
      Rake::Task["couchdb:refresh_design_docs_on_db"].execute  
    end
  end

  # refresh design docs for a specific db
  # e.g. rake refresh_design_docs_on_db SERVER="http://127.0.0.1:5984" DATABASE=my_database 
  task (:refresh_design_docs_on_db => :environment) do
  
    db_name = ENV['DATABASE']  
    server_location = ENV['SERVER']
    
    CouchRestMigration::update_all_design_docs( ENV["SERVER"], ENV['DATABASE'] )

  end


end