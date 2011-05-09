class Admin::SessionsController < Admin::ApplicationController

  skip_before_filter :get_session_user 

  # create a new session - i.e. log in.
  def create
    
    authenticated_account = Account.authenticate( params[:email], params[:password] )
    
    if (authenticated_account)
      
      # successfully authenticated - populate the session variable and then send them on their merry way.
      session[:account] = authenticated_account.name
      
      redirect_to admin_articles_path
      
    else
      
      flash[:notice] = 'Invalid login details'
      redirect_to new_admin_session_path
      
    end
    
  end

end