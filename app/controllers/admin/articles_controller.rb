class Admin::ArticlesController < Admin::ApplicationController
  
  before_filter :get_article_by_permalink, :only => [:edit, :update, :destroy, :preview]
  
  def preview
    render :template => "articles/show", :layout => 'articles'
  end
  
  def index
    @articles = @blog.articles.by_created_at.descending
  end
  
  def new
    @article = @blog.articles.new
  end

  def edit
  end
  
  def update   
    update_article
  end
  
  def create
    @article = @blog.articles.new
    update_article
  end
    
  def destroy
    @article.destroy
    redirect_to admin_articles_path
  end
  
  private
  
    def update_article
      @article.set_published( params["article"]["is_published"]=="true", session[:account])
      @article.set_permalink( params["article"]["permalink"] ) if params["article"]["permalink"]
      
      if @article.update_attributes(params[:article])
        redirect_to edit_admin_article_path(@article.permalink)
      else
         flash[:notice] = 'save failed'
         redirect_to :back
      end
    end
  
    def get_article_by_permalink
      @article = @blog.articles.by_permalink(:key => params[:id]).first      
      render :file => "#{Rails.root.to_s}/public/404.html", :status => 404 and return false unless @article
      Rails.logger.debug("got article")
    end
end