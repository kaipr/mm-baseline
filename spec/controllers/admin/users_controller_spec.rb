require File.dirname(__FILE__) + '/../../spec_helper'

def mock_user(options = {})
  mock_model(User, {:login => 'jan', :state => 'active', :valid? => true, :suspended? => false})
end

describe Admin::UsersController, 'routing' do
  it "should map index" do
    route_for(:controller => "admin/users", :action => "index").should == "/admin/users"
  end
  it "should map toggle_suspension" do
    route_for(:controller => "admin/users", :action => "toggle_suspension", :id => 1).should == "/admin/users/1/toggle_suspension"
  end
  it "should map destroy" do
    route_for(:controller => "admin/users", :action => "destroy", :id => 1).should == "/admin/users/1"
  end
  it "should map purge" do
    route_for(:controller => "admin/users", :action => "purge", :id => 1).should == "/admin/users/1/purge"
  end
end

describe Admin::UsersController, 'action' do
  
  before do 
    admin = mock_user
    admin.stub!(:has_role?).and_return(true)
    login_me(admin)
    @user = mock_user
    User.stub!(:find).and_return(@user)
  end
  
  describe 'toggle_suspension' do
  
    it "should suspend user" do
      @user.should_receive(:suspended?).and_return(false)
      @user.should_receive :suspend!
      get :toggle_suspension, :id => @user.id
    end
    
    it "should activate user" do
      @user.should_receive(:suspended?).and_return(true)
      @user.should_receive :unsuspend!
      get :toggle_suspension, :id => @user.id
    end
    
    it "should redirect to index" do
      @user.stub!(:suspended?).and_return(false)
      @user.stub!(:suspend!)
      get :toggle_suspension, :id => @user.id
      response.should redirect_to(admin_users_path)
    end
    
  end
  
  describe "delete" do
  
    it "should delete user" do
      @user.should_receive :delete!
      delete :destroy, :id => @user.id
    end
    
    it "should redirect to index" do
      @user.stub!(:delete!)
      delete :destroy, :id => @user.id
      response.should redirect_to(admin_users_path)
    end
  
  end
  
  describe "purge" do
    
    it "should purge user" do
      @user.should_receive :destroy
      delete :purge, :id => @user.id
    end
    
    it "should redirect to index" do
      @user.stub!(:destroy)
      delete :purge, :id => @user.id
      response.should redirect_to(admin_users_path)
    end
    
  end
  
end
