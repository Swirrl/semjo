ENV["RAILS_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)
require 'rails/test_help'

class Account < CouchRest::Model::Base   
  use_database CouchRest.database!( "#{APP_CONFIG['couch_db_location']}/semjo_test_central" )  
end

class Blog < CouchRest::Model::Base
  use_database CouchRest.database!( "#{APP_CONFIG['couch_db_location']}/semjo_test_central" )  
end

class ActiveSupport::TestCase
  setup :drop_and_create_dbs, :create_blog

  def create_blog
    @blog = Factory.create(:blog)
  end

  def drop_and_create_dbs
    
    Blog.all.each do |b|    
      b.articles.all.each {|a| a.destroy}
      b.pages.all.each {|p| p.destroy}  
      b.blog_users.all.each {|bu| bu.destroy}
      b.destroy
    end
    
    Account.all.each do |a|
      a.destroy
    end
  end
   
end

