class PagesController < ApplicationController

  before_filter :get_page_by_permalink, :only => [:show]

  before_filter :get_most_recent_article, :if => proc { |c| @blog && @blog.expire_pages_on_article_update }

  def show

    last_modified = @page.updated_at

    if @blog.expire_pages_on_article_update && @most_recent_article
      if @most_recent_article.updated_at > @page.updated_at
        last_modified = @most_recent_article.updated_at
      end
    end

    fresh_when(:last_modified => last_modified, :public => true, :etag => @page) if (Rails.env.production?)
  end

  private

    def get_page_by_permalink
      @page = @blog.pages.by_permalink(:key => params[:id]).first

      unless @page && @page.is_published?
        render :template => "404.erb", :status => 404, :layout => 'pages' and return false
      end
    end

end