require File.dirname(__FILE__) + '/../test_helper'

class ArticlesControllerTest < ActionController::TestCase
  
  def setup
    @article = @blog.articles.new(Factory.build(:article))
    @article.save
    
    @unpublished_article = @blog.articles.new(Factory.build(:unpublished_article))
    @unpublished_article.save
  end
  
  def test_blog_doesnt_exist
    @request.host = "non.exist.ant"
    get :show, :id => @article.permalink
    assert_response :missing
  end
  
  def test_show_published
    @request.host = @blog.hosts[0]
    get :show, :id => @article.permalink
    assert_response :success
  end
  
  def test_show_unpublished
    @request.host = @blog.hosts[0]
    get :show, :id => @unpublished_article.permalink
    assert_response :missing
  end
  
  def test_show_home   
    @request.host = @blog.hosts[0]
    get :index
    assert_response :success
  end
  
  def test_feed
    @request.host = @blog.hosts[0]
    get :feed, :format => "rss"
    assert_response :success
  end
   
 
end
