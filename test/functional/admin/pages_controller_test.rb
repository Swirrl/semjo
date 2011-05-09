require File.dirname(__FILE__) + '/../../test_helper'

class Admin::PagesControllerTest < ActionController::TestCase
  
  def setup
    @blog_user = @blog.blog_users.new(Factory.build(:blog_user))
    @blog_user.save
    
    @account = Factory.create(:account)
    
    @page = @blog.pages.new(Factory.build(:page))
    @page.save
    
    @unpublished_page = @blog.pages.new(Factory.build(:unpublished_page))
    @unpublished_page.save
  end

  def test_preview_logged_in
    @request.session[:account] = @account.name
    @request.host = @blog.hosts[0]
    get :preview, :id => @unpublished_page.permalink #checking it works for unpublished ones.
    assert_response :success
  end

  def test_preview_logged_out
    @request.host = @blog.hosts[0]
    get :preview, :id => @unpublished_page.permalink #checking it works for unpublished ones.
    assert_response :redirect
    assert_redirected_to :action => "new", :controller => "sessions" #redirect to login.
  end

  def test_index_logged_in
    @request.session[:account] = @account.name
    @request.host = @blog.hosts[0]
    get :index
    assert_response :success
    assert assigns["pages"]
  end

  def test_index_logged_out
    @request.host = @blog.hosts[0]
    get :index
    assert_response :redirect
    assert_redirected_to :action => "new", :controller => "sessions" #redirect to login.
  end

  def test_new_logged_in
    @request.session[:account] = @account.name
    @request.host = @blog.hosts[0]
    get :new
    assert_response :success
    assert assigns["page"]
  end

  def test_new_logged_out
    @request.host = @blog.hosts[0]
    get :new
    assert_response :redirect
    assert_redirected_to :action => "new", :controller => "sessions" #redirect to login.
  end

  def test_edit_logged_in
    @request.session[:account] = @account.name
    @request.host = @blog.hosts[0]    
    get :edit, :id => @page.permalink  
    assert_response :success
    assert assigns["page"]
  end

  def test_edit_logged_out
    @request.host = @blog.hosts[0]
    get :edit, :id => @page.permalink
    assert_response :redirect
    assert_redirected_to :action => "new", :controller => "sessions" #redirect to login.
  end

  def test_update_logged_in
    @request.session[:account] = @account.name
    @request.host = @blog.hosts[0]
    put :update, :id => @page.permalink, :page => {:title => @page.title, :content => "contento", :is_published => "true"}
    assert_response :redirect
    assert_redirected_to :action => "edit", :id => @page.permalink
  end

  def test_update_logged_out
    @request.host = @blog.hosts[0]
    put :update, :id => @page.permalink, :page => {:title => @page.title, :content => "contento", :is_published => "true"}
    assert_response :redirect
    assert_redirected_to :action => "new", :controller => "sessions" #redirect to login.
  end

  def test_create_logged_in
    @request.session[:account] = @account.name
    @request.host = @blog.hosts[0]
    post :create, :page => {:title => Factory.build(:page_with_unusual_chars).title, :content => "contento", :is_published => "true"}
    assert_response :redirect
    assert_redirected_to :action => "edit", :id => "this-is-a-title-456"
  end

  def test_create_logged_out
    @request.host = @blog.hosts[0]
    post :create, :page => {:title => @page.title, :content => "contento", :is_published => "true"}
    assert_response :redirect
    assert_redirected_to :action => "new", :controller => "sessions" #redirect to login.
  end

  def test_destroy_logged_in
    @request.session[:account] = @account.name
    @request.host = @blog.hosts[0]
    delete :destroy, :id => @page.permalink
    assert_response :redirect
    assert_redirected_to :action => "index"
  end

  def test_destroy_logged_out
    @request.host = @blog.hosts[0]
    delete :destroy, :id => @page.permalink
    assert_response :redirect
    assert_redirected_to :action => "new", :controller => "sessions" #redirect to login.
  end

end