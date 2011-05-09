class Admin::PagesController < Admin::ApplicationController
  
  before_filter :get_page_by_permalink, :only => [:edit, :update, :destroy, :preview]
  
  def preview
    render :template => "pages/show", :layout => 'pages'
  end
  
  def index
    @pages = @blog.pages.by_created_at.descending
  end
  
  def new
    @page = @blog.pages.new
  end

  def edit
  end
  
  def update   
    update_page
  end
  
  def create
    @page = @blog.pages.new
    update_page
  end
  
  def destroy
    @page.destroy  
    redirect_to admin_pages_path
  end
  
  private
  
    def update_page
      @page.set_published( params["page"]["is_published"]=="true", session[:account])
      @page.set_permalink( params["page"]["permalink"] ) if params["page"]["permalink"]
      
      if @page.update_attributes(params[:page])
        redirect_to edit_admin_page_path(@page.permalink)
      else
        flash[:notice] = 'save failed'
        redirect_to :back
      end
    end

    def get_page_by_permalink
      @page = @blog.pages.by_permalink(:key => params[:id]).first
      render :file => "#{Rails.root.to_s}/public/404.html", :status => 404 and return false unless @page
    end
  
end