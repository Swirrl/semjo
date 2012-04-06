class ArticlesController < ApplicationController

  before_filter :get_most_recent_article, :only => [:index, :show, :feed]
  before_filter :get_article_by_permalink, :only => [:show]

  # show an article. Don't need to be logged in, but don't allow viewing of unpublished articles.
  def show
    fresh_when(:last_modified => @article.updated_at, :public => true, :etag => @article) if Rails.env.production?
  end

  def index
    if @most_recent_article
      if (!Rails.env.production?) || stale?(:last_modified => @most_recent_article.updated_at, :public => true, :etag => @most_recent_article)
        @page = params[:page].to_i || 1
        @page = 1 if @page < 1
        @articles = @blog.articles.by_published_at.descending.page(@page).per(@blog.articles_per_page)
      end
    end
  end

  def feed
    if (!Rails.env.production?) || stale?(:last_modified => (@most_recent_article ? @most_recent_article.updated_at : Time.now), :public => true, :etag => @most_recent_article)
      # At the moment, only provide the 10 latest articles in the feed.
      @articles = @blog.articles.by_published_at.descending.limit(10)
      render :layout => false
    end
  end

  private

    def get_article_by_permalink
      @article = @blog.articles.by_permalink(:key => params[:id]).first

      unless @article && @article.is_published?
        render :template => "404.erb", :status => 404, :layout => 'pages' and return false
      end
    end

end