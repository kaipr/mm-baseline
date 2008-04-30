class UsersController < ApplicationController
  # Protect these actions behind an admin login
  permit 'admin', :only => [:edit, :update]
  before_filter :find_user, :only => [:edit, :update]
  

  # render edit.html.erb
  def edit
  end
  
  def update
    if @user.update_attributes(params[:user])
      flash[:notice] = 'Update des Benutzers erfolgreich!'
    else
      flash[:notice] = 'Update des Benutzers fehlgeschlagen!'
    end
    redirect_to users_path
  end

  # render new.html.erb
  def new
  end

  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    @user = User.new(params[:user])
    @user.register! if @user.valid?
    if @user.errors.empty?
      # self.current_user = @user
      redirect_back_or_default('/')
      flash[:notice] = "Danke, das Sie sich angemeldet haben!"
    else
      render :action => 'new'
    end
  end

  def activate
    user = params[:activation_code].blank? ? false : User.find_by_activation_code(params[:activation_code])
    if user && !user.active?
      user.activate!
      flash[:notice] = "Aktivierung erfolgreich!"
    end
    redirect_to(new_session_path)
  end

protected
  def find_user
    @user = User.find(params[:id])
  end

end
