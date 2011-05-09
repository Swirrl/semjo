class Admin::ApplicationController < ApplicationController
  
  layout 'admin'
  
  before_filter :get_session_user
  
  private
  
    def get_session_user
      
      Rails.logger.debug "BLOG: #{@blog.name}"
      
      Rails.logger.debug @blog.blog_users
      
      if session[:account]
        session_blog_user = @blog.blog_users.by_account(:key => session[:account]).first
        @session_account = Account.get(session_blog_user.account) if session_blog_user
      end
        
      # if we don't have a logged in user, redirect to the log in screen
      redirect_to new_admin_session_path unless @session_account
        
    end
  
end