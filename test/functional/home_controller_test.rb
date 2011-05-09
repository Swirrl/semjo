require File.dirname(__FILE__) + '/../test_helper'

class HomeControllerTest < ActionController::TestCase
  
  def test_redirects
    @request.host = @blog.hosts[0]
    get :show    
    assert_response :redirect
    assert_redirected_to @blog.home_path
  end
end
  