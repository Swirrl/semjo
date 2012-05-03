require File.dirname(__FILE__) + '/../../test_helper'

class Admin::ArticlesControllerTest < ActionController::TestCase

  def setup
    @blog_user = @blog.blog_users.new(FactoryGirl.build(:blog_user))
    @blog_user.save

    @account = FactoryGirl.create(:account)

    @article = @blog.articles.new(FactoryGirl.build(:article))
    @article.save

    @unpublished_article = @blog.articles.new(FactoryGirl.build(:unpublished_article))
    @unpublished_article.save

  end

  def test_preview_logged_in
    @request.session[:account] = @account.name
    @request.host = @blog.hosts[0]
    get :preview, :id => @unpublished_article.permalink #checking it works for unpublished ones.
    assert_response :success
  end

  def test_preview_logged_out
    @request.host = @blog.hosts[0]
    get :preview, :id => @unpublished_article.permalink #checking it works for unpublished ones.
    assert_response :redirect
    assert_redirected_to :action => "new", :controller => "sessions" #redirect to login.
  end

  def test_index_logged_in
    @request.session[:account] = @account.name
    @request.host = @blog.hosts[0]
    get :index
    assert_response :success
    assert assigns["articles"]
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
    assert assigns["article"]
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
    get :edit, :id => @article.permalink
    assert_response :success
    assert assigns["article"]
  end

  def test_edit_logged_out
    @request.host = @blog.hosts[0]
    get :edit, :id => @article.permalink
    assert_response :redirect
    assert_redirected_to :action => "new", :controller => "sessions" #redirect to login.
  end

  def test_update_logged_in
    @request.session[:account] = @account.name
    @request.host = @blog.hosts[0]
    put :update, :id => @article.permalink, :article => {:title => @article.title, :content => "contento", :is_published => "true"}
    assert_response :redirect
    assert_redirected_to :action => "edit", :id => @article.permalink
  end

  def test_update_logged_out
    @request.host = @blog.hosts[0]
    put :update, :id => @article.permalink, :article => {:title => @article.title, :content => "contento", :is_published => "true"}
    assert_response :redirect
    assert_redirected_to :action => "new", :controller => "sessions" #redirect to login.
  end

  def test_create_logged_in
    @request.session[:account] = @account.name
    @request.host = @blog.hosts[0]
    post :create, :article => {:title => FactoryGirl.build(:article_with_unusual_chars).title, :content => "contento", :is_published => "true"}
    assert_response :redirect
    assert_redirected_to :action => "edit", :id => "this-is-a-title-456"
  end

  def test_create_logged_out
    @request.host = @blog.hosts[0]
    post :create, :article => {:title => @article.title, :content => "contento", :is_published => "true"}
    assert_response :redirect
    assert_redirected_to :action => "new", :controller => "sessions" #redirect to login.
  end

  def test_destroy_logged_in
    @request.session[:account] = @account.name
    @request.host = @blog.hosts[0]
    delete :destroy, :id => @article.permalink
    assert_response :redirect
    assert_redirected_to :action => "index"
  end

  def test_destroy_logged_out
    @request.host = @blog.hosts[0]
    delete :destroy, :id => @article.permalink
    assert_response :redirect
    assert_redirected_to :action => "new", :controller => "sessions" #redirect to login.
  end

end