module CouchRestMigration
  def self.update_all_design_docs
    
    puts Rails.env
    
    config = YAML.load_file("#{Rails.root.to_s}/config/config.yml")[Rails.env]
    central_db_location = config["couch_db_location"]
    
    central_db = CouchRest::Database.new(CouchRest::Server.new(central_db_location), "semanticjournal")
    update_design_docs(central_db) # top-level models
    
    Blog.all.each do |blog|
      puts "for #{blog.name}"
      update_design_docs(blog.proxy_database)
    end
  end
  
  def self.update_design_docs(db)
    CouchRest::Model::Base.subclasses.each{|klass| klass.save_design_doc!(db) if klass.respond_to?(:save_design_doc!)}
  end
end

# Command to run after a capistrano deploy:
#$ rails runner "CouchRestMigration.update_all_design_docs"