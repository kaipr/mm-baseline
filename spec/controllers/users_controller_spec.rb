require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController, "routing" do
  it "should map show" do
    route_for(:controller => "users", :action => "show", :id => 'abc').should == "/users/abc"
  end
  it "should map new" do
    route_for(:controller => "users", :action => "new").should == "/users/new"
  end
  it "should map edit" do
    route_for(:controller => "users", :action => "edit", :id => 'abc').should == "/users/abc/edit"
  end
  it "should map update" do
    route_for(:controller => "users", :action => "update", :id => 'abc').should == "/users/abc"
  end
  it "should map activate/:activation_code" do
    route_for(:controller => "users", :action => 'activate', :activation_code => 'dude_code').should == "/activate/dude_code"
  end
  it "should map recover_password" do
    route_for(:controller => "users", :action => 'recover_password').should == "/users/recover_password"
  end 
end

describe UsersController, "access control" do
  it "should require login" do
    [:edit,:update].each do |action|
      get action
      response.should redirect_to(new_session_path)
    end
  end
end
describe UsersController, 'requests to new' do
  it "should be successfull" do
    get :new
    response.should be_success
    response.should render_template('new')
  end
end

describe UsersController, 'requests to create' do
  before do
    @user_params = { "login" => 'quire', "email" => 'quire@example.com',
        "password" => 'quire', "password_confirmation" => 'quire' }
    @band_params = @user_params.merge("bandname" => 'bandname')
    @user = mock_user
    @user.stub!(:errors).and_return([])
  end
  it "should create a new user" do
    User.should_receive(:new).with(@user_params).and_return(@user)
    @user.should_receive(:register!).and_return(true)
    post :create, :user => @user_params
    response.should be_redirect
  end
  it "should not log in the user" do
    User.should_receive(:new).with(@user_params).and_return(@user)
    @user.should_receive(:register!).and_return(true)
    post :create, :user => @user_params
    controller.send(:logged_in?).should be_false
  end
  it "should re-render new template on failure" do
    @user_params.merge!("password_confirmation" => nil)
    post :create, :user => @user_params
    response.should render_template('new')
  end
end

describe UsersController, 'requests to activate' do

  def stub_logged_in(ret=true)
    stub!(:logged_in?).and_return(ret)
  end

  def stub_current_user(user=mock_user)
    stub!(:current_user).and_return(user)    
  end


  before do
    # @deliveries = ActionMailer::Base.deliveries
    # @deliveries.clear
  end

  it "should activate the requested user" do
    stub_logged_in(true)
    user = mock_user(:login => 'aaron', :password => 'test', :password_confirmation => 'test', 
      :activated? => false, :activation_code => 'abc')
    user.stub!(:active?).and_return(false)
    user.should_receive(:activate!)
    User.stub!(:find_by_activation_code).and_return(user)
    stub_current_user(user)
    get :activate, :activation_code => 'abc'
    response.should redirect_to(new_session_url)
  end
end

describe UsersController, "requests to edit" do
  before do
    @user = mock_user
    @user.stub!(:has_role?).with('admin').and_return(true)
    User.stub!(:find).and_return(@user)
    login_me(@user)
    get :edit, :id => @user.id
  end
  
  it "should be a success" do
    response.should be_success
  end
  it "should load the current user" do
    assigns(:user).id.should eql(@user.id)
  end
end

describe UsersController, 'requests to update' do
  before do
    @user = mock_user
    @user.stub!(:has_role?).with('admin').and_return(true)
    User.stub!(:find).and_return(@user)
    login_me(@user)
  end
  it "should update the requested user attributes" do
    @user.should_receive(:update_attributes).with("firstname" => 'new_firstname').and_return(true)
    put :update, :user => {"firstname" => 'new_firstname'}
    #response.should redirect_to(user_path(@user))
  end    
end
