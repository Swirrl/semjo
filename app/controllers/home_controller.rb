class HomeController < ApplicationController
  
  def show
    redirect_to @blog.home_path
  end

end