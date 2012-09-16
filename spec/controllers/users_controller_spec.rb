require 'spec_helper'

describe UsersController do
  describe 'new' do
    it 'should render the new user form' do
      get :new
      response.should render_template('new')
    end
  end

  describe 'create' do
    context 'when successful' do
      before(:each) do
        @params = { :user => {
          :first_name => 'Clark',
          :last_name => 'Kent',
          :email => 'ckent@dailyplanet.com',
          :password => 'password' }}
      end

      it 'should create a new user' do
        expect {
          post :create, @params
        }.to change(User, :count)

        User.last.email.should == 'ckent@dailyplanet.com'
      end

      # TODO: we'll probably want to confirm their email first
      it 'should log the new user in automatically' do
        post :create, @params
        session[:user_id].should == User.last.id
      end

      it 'should redirect to the home page' do
        post :create, @params
        response.should redirect_to(root_path)
      end
    end

    context 'when unsuccessful' do
      before(:each) do
        @params = { :user => { :email => 'ckent@dailyplanet.com' }}
      end

      it 'should re-render the form with errors' do
        post :create, @params
        response.should render_template('new')
      end
    end
  end

  describe 'show' do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @params = { :id => @user.url }
    end

    it 'should render the user profile' do
      get :show, @params
      response.should render_template('show')
    end
  end
end
