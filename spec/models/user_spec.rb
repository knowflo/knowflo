require 'spec_helper'

describe User do
  describe 'email' do
    before(:each) { FactoryGirl.create(:user, :email => 'nodups@voltron.com') }
    it { should have_valid(:email).when('keith@voltron.com') }
    it { should_not have_valid(:email).when(nil, '') }
    it { should_not have_valid(:email).when('nodups@voltron.com') }
    it { should_not have_valid(:email).when('thisisnotanemailaddress') }
  end

  describe 'password' do
    it { should have_valid(:password).when('password') }
    it { should_not have_valid(:password).when(nil, '') }
    it { should_not have_valid(:password).when('2shrt') }
  end

  describe 'name' do
    it { should have_valid(:first_name).when('Clark', 'Bruce') }
    it { should_not have_valid(:first_name).when(nil, '') }
    it { should have_valid(:last_name).when('Kent', 'Wayne') }
    it { should_not have_valid(:last_name).when(nil, '') }

    it 'should be the first name plus last name' do
      FactoryGirl.create(:user, :first_name => 'Bruce', :last_name => 'Wayne').name.should == 'Bruce Wayne'
    end
  end

  describe 'url' do
    before(:each) do
      @user = FactoryGirl.create(:user, :first_name => 'Wally', :last_name => 'West')
    end

    it 'should be created from the name' do
      @user.url.should == 'wally-west'
    end

    it 'should be unique' do
      user = FactoryGirl.create(:user, :first_name => 'Wally', :last_name => 'West')
      user.url.should == 'wally-west-1'
    end

    it { should_not have_valid(:url).when(nil, '') }
    it { should_not have_valid(:url).when('wally-west') }
  end

  describe 'avatar' do
    it 'should try to use a gravatar for the avatar url' do
      user = FactoryGirl.build(:user, :email => 'nap@zerosum.org')
      user.avatar_url.should == 'http://www.gravatar.com/avatar/9ea5b82a23b081cdc7e2ac5e2282c852.jpg?s=80&d=mm'
    end
  end

  describe 'remember token' do
    it 'is created automatically' do
      FactoryGirl.create(:user).remember_token.should_not be_nil
    end
  end

  describe 'if using omniauth' do
    before(:each) do
      User.any_instance.stubs(:using_omniauth?).returns(true)
    end

    it { should have_valid(:auth_uid).when('12345') }
    it { should_not have_valid(:auth_uid).when(nil) }
    it { should have_valid(:auth_provider).when('facebook') }
    it { should_not have_valid(:auth_provider).when(nil) }

    it 'requires a unique auth uid' do
      FactoryGirl.create(:user, :auth_uid => '1234', :auth_provider => 'facebook')
      dup = FactoryGirl.build(:user, :auth_uid => '1234', :auth_provider => 'facebook')
      dup.should_not be_valid
      dup.errors[:auth_uid].should include('has already been taken')
    end
  end

  describe 'create with omniauth' do
    before(:each) do
      @auth_data = {
        'provider' => 'facebook',
        'uid' => '1234567',
        'info' => {
          'first_name' => 'Wally',
          'last_name' => 'West',
          'email' => 'flash@jla.com',
          'nickname' => 'flash'
        }
      }
    end

    it 'creates a new user' do
      expect {
        user = User.create_with_omniauth!(@auth_data)
      }.to change(User, :count)
    end

    it 'records user name and email information (if available)' do
      user = User.create_with_omniauth!(@auth_data)
      user.first_name.should == 'Wally'
      user.last_name.should == 'West'
      user.email.should == 'flash@jla.com'
    end

    it 'fails if provider data is missing' do
      @auth_data['provider'] = nil

      expect {
        expect {
          user = User.create_with_omniauth!(@auth_data)
        }.to raise_error(ActiveRecord::RecordInvalid)
      }.to_not change(User, :count)
    end
  end

  describe 'authenticate' do
    before(:each) do
      @user = FactoryGirl.create(:user)
    end

    it 'should succeed' do
      User.authenticate(@user.email, 'password').should be_true
    end

    it 'should fail if the password is incorrect' do
      User.authenticate(@user.email, 'wrongpass').should be_false
    end

    it 'should fail if the email does not exist' do
      User.authenticate('robeast@voltron.com', 'password').should be_false
    end
  end

  describe 'generate_password' do
    it 'should generate a temporary password' do
      user = User.new
      user.generate_password
      user.password.should_not be_blank
    end
  end
end
