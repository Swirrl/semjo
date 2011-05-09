require File.dirname(__FILE__) + '/../test_helper'

class PagesControllerTest < ActionController::TestCase
  
  def setup
    @page = @blog.pages.new(Factory.build(:page))
    @page.save
    
    @unpublished_page = @blog.pages.new(Factory.build(:unpublished_page))
    @unpublished_page.save
  end
  
  def test_blog_doesnt_exist
    @request.host = "non.exist.ant"
    get :show, :id => @page.permalink
    assert_response :missing
  end
  
  def test_show_published
    @request.host = @blog.hosts[0]
    get :show, :id => @page.permalink
    assert_response :success
  end
  
  def test_show_unpublished
    @request.host = @blog.hosts[0]
    get :show, :id => @unpublished_page.permalink
    assert_response :missing
  end   
 
end
