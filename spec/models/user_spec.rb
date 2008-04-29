require File.dirname(__FILE__) + '/../spec_helper'

def create_user(options = {})
  default_options = {:login => 'dude', :password => 'test', :password_confirmation => 'test', :email => 'test@test.com'}
  o = User.create!(default_options.merge(options))
  unless options.keys.include?(:activation_code)
    o.activation_code = nil
    o.activated_at = Time.now
    o.save!
    o.activate!
  end
  o
end

describe User, "validations" do
  it "should validate presence of login" do
    User.should have_validated_presence_of(:login)
  end
  it "should validate presence of email" do
    User.should have_validated_presence_of(:email)
  end
  it "should validate presence of password" do
    User.should have_validated_presence_of(:password, :if => :password_required?)
  end
  it "should validate presence of password_confirmation" do
    User.should have_validated_presence_of(:password_confirmation)
  end
  it "should validate format of email" do
    user = User.new(:login => 'valid', :password => 'password', :password_confirmation => 'password')
    valid_emails.each do |email|
      user.email = email
      user.should be_valid
    end
    invalid_emails.each do |email|
      user.email = email
      user.should_not be_valid
    end
  end
  def valid_emails
    ['test@test.com','test@test.test.test.com','test.test@test.com','test-test@test-test.com','test_test@test_test.com']
  end
  def invalid_emails
    ['testtest.com','@test.com','täst@test.com']
  end
end

describe User, 'authentification' do

  it "should require login" do
    user = User.new({:email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' })    
    user.should have_at_least(1).error_on(:login)
  end

  it "should require email" do
    user = User.new({:login => 'quire', :password => 'quire', :password_confirmation => 'quire' })    
    user.should have_at_least(1).error_on(:email)
  end

  it "should require password" do    
    user = User.new({:login => 'quire', :email => 'quire@example.com', :password_confirmation => 'quire' })    
    user.should have_at_least(1).error_on(:password)
  end

  it "should require password_confirmation" do    
    user = User.new({:login => 'quire', :email => 'quire@example.com', :password => 'quire' })    
    user.should have_at_least(1).error_on(:password_confirmation)
  end

  it "should not rehash password" do
    user = create_user(:password => 'test_password', :password_confirmation => 'test_password')
    new_login = 'new_login'
    user.update_attributes(:login => new_login)
    User.authenticate(new_login, 'test_password').should_not be_nil
  end

  it "should authenticate user with login" do
    user = create_user(:password => 'test_password', :password_confirmation => 'test_password')
    User.authenticate(user.login, 'test_password').should_not be_nil
  end

  it "should not authenticate deleted user" do
    user = create_user(:password => 'test_password', :password_confirmation => 'test_password')
    user.delete!
    User.authenticate(user.login, 'test_password').should be_nil
  end
  it "should set remember token" do
    user = create_user
    user.remember_me
    user.remember_token.should_not be_nil
  end
  it "should unset remember token" do
    user = create_user
    user.remember_me
    user.remember_token.should_not be_nil
    user.forget_me
    user.remember_token.should be_nil
  end
  it "should remember me for one week" do
    user = create_user
    before = 1.week.from_now.utc
    user.remember_me_for 1.week
    after = 1.week.from_now.utc
    user.remember_token.should_not be_nil
    user.remember_token_expires_at.should_not be_nil
    user.remember_token_expires_at.between?(before, after).should be_true
  end
  it "should remember me until one week" do
    user = create_user
    time = 1.week.from_now.utc
    user.remember_me_until time
    user.remember_token.should_not be_nil
    user.remember_token_expires_at.should_not be_nil
    user.remember_token_expires_at.should equal(time)
  end
  it "should remember me default two weeks" do
    user = create_user
    before = 2.weeks.from_now.utc
    user.remember_me
    after = 2.weeks.from_now.utc
    user.remember_token.should_not be_nil
    user.remember_token_expires_at.should_not be_nil
    user.remember_token_expires_at.between?(before, after).should be_true
  end
end

describe User, "in test" do
  before do
    @user = create_user
  end
  it "should be active" do
    @user.activation_code.should be_nil
    @user.activated_at.should_not be_nil
    @user.should be_active
  end
end

describe User, 'states' do
  before do
    @user = create_user
  end
  it "should allow delete" do
    @user.deleted_at.should be_nil
    @user.should_not be_deleted
    @user.delete!
    @user.deleted_at.should_not be_nil
    @user.should be_deleted
  end
end