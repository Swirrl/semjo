# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :set_current_blog
  
  private
    
    def set_current_blog
            
      # first, try to match the whole host to a blog's host in the db
      @blog = Blog.by_hosts(:key => request.host, :limit => 1, :reduce=>false).first 
            
      # redirect to the first item in the hosts array (the 'canonical domain' for this blog.)
      # this ensures that things like disqus work fine, and don't end up with multiple discussion threads:
      # (one for each url.)
      if @blog && @blog.hosts && @blog.hosts[0] != request.host
        parts = []
        parts << request.protocol
        parts << @blog.hosts[0]
        parts << request.path
        redirect_to parts.join
      end
       
      unless @blog  
        render :file => "#{Rails.root.to_s}/public/404.html", :status => 404 
        return false #  quit filter chain
      end
      
      # For now, this is inside the project folder, but could be somewhere else, and symlinked in.
      prepend_view_path ["#{Rails.root.to_s}/app/views/themes/#{@blog.name}/"]
      prepend_view_path ["#{Rails.root.to_s}/app/views/themes/symlinked/#{@blog.name}/"]
    end    
    
end
