class PagesController < ApplicationController

  before_filter :get_page_by_permalink, :only => [:show]
  
  def show
    fresh_when(:last_modified => @page.updated_at, :etag => @page, :public => true) if (APP_CONFIG['caching']) 
  end
  
  private
  
    def get_page_by_permalink
      @page = @blog.pages.by_permalink(:key => params[:id]).first
      
      unless @page && @page.is_published?
        render :template => "404.erb", :status => 404, :layout => 'pages' and return false 
      end  
    end
  
end