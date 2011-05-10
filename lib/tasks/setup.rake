namespace :semjo do
  
  desc "creates the couch 'core' database
  e.g. rake semjo:create_semjo_db
  Note: COUCH_SERVER is optional and defaults to localhost"
  task (:create_semjo_db => :environment) do
    couch_server = ENV['COUCH_SERVER'] || "http://127.0.0.1:5984" 
    svr = CouchRest::Server.new(couch_server)   
    puts "success" if svr.create_db("semanticjournal") 
  end
  
  desc "deletes the semanticjournal 'core' database. USE WITH CARE!!
  Note: COUCH_SERVER is optional and defaults to localhost"
  task (:delete_semjo_db => :environment) do
    couch_server = ENV['COUCH_SERVER'] || "http://127.0.0.1:5984"    
    svr = CouchRest::Server.new(couch_server)    
    sitedb = CouchRest::Database.new(svr, "semanticjournal")
    sitedb.delete!
  end
  
  desc "creates a new blog...
  e.g. rake semjo:create_new_blog BLOG_NAME='jamestkirk' BLOG_HOST='jimkirksblog.com' COUCH_SERVER='http://127.0.0.1:5984'
  Note: BLOG_HOST and COUCH_SERVER are optional. You need to specify the RAILS_ENV so that the blog model knows what server to use for the semanticjournal db
  Remember: if in dev mode, you'll need to also set up an /etc/hosts entry or passenger alias"
  task (:create_new_blog => :environment) do
        
    blog_name = ENV['BLOG_NAME']
    blog_host = ENV['BLOG_HOST']
    couch_server = ENV['COUCH_SERVER'] || "http://127.0.0.1:5984"
    
    svr = CouchRest::Server.new(couch_server)    
        
    # make the blog db
    blogdb = CouchRest::Database.new(svr, blog_name)
    blogdb.create!
    
    b = Blog.new    
    b.name = blog_name
    b.hosts = [blog_host] if blog_host
    puts "success" if b.save
    
  end
    
  desc "creates an admin user in the specifed blog, with the specified acct name, first_name, last_name, uri, pwd and email
  e.g. rake semjo:create_user ACCOUNT_NAME=jim DISPLAY_NAME='jim kirk' PERSONAL_URI='http://jimkirksblog.com/me.rdf#me' PASSWORD='pwd1' EMAIL='jamestkirk@starshipenterprise.org' BLOG_NAME='jamestkirk' COUCH_SERVER='http://127.0.0.1:5984'
  Note: COUCH_SERVER defaults to local server"
  task (:create_user => :environment) do
    
    account_name = ENV['ACCOUNT_NAME']
    display_name = ENV['DISPLAY_NAME']
    personal_uri = ENV['PERSONAL_URI']
    password = ENV['PASSWORD']
    email = ENV['EMAIL']
    blog_name = ENV['BLOG_NAME']
    couch_server = ENV['COUCH_SERVER'] || "http://127.0.0.1:5984"
    
    svr = CouchRest::Server.new(couch_server)    
    blogdb = CouchRest::Database.new(svr, blog_name)
    
    acc = Account.get(account_name)
    
    unless acc
      puts 'making new account'
      acc = Account.new
      acc.name = account_name
      acc.display_name = display_name
      acc.personal_uri = personal_uri
      acc.email = email
      acc.password = password
      acc.confirm_password = password
      
      puts "error creating account: #{acc.errors.inspect}" unless acc.save
    end
    
    blog = Blog.by_name(:key => blog_name).first

    bu = blog.blog_users.new
    bu.account = acc.name
    
    puts "success!" if bu.save
    
    
    
    
  end
  
end