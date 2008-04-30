class Admin::UsersController < ApplicationController

  permit 'admin'
  before_filter :find_user, :only => [:toggle_suspension, :destroy, :purge]

  def index
    @users = User.find :all, :order => 'state'
  end
  
  def toggle_suspension
    @user.suspended? ? @user.unsuspend! : @user.suspend!
    redirect_to admin_users_path
  end

  def destroy
    @user.delete!
    redirect_to admin_users_path
  end

  def purge
    @user.destroy
    redirect_to admin_users_path
  end
  
  protected
  
  def find_user
    @user = User.find(params[:id])
  end

end
