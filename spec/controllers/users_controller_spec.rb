require 'spec_helper'

describe UsersController do
  let(:user) { FactoryGirl.create(:user) }

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
    it 'renders the user profile' do
      get :show, id: user.url
      response.should render_template('show')
    end
  end

  describe 'edit' do
    before(:each) do
      login(user)
    end

    it 'renders the user settings template' do
      get :edit, id: user.url
      response.should render_template('edit')
    end

    it 'only allows a user to edit their own profile' do
      get :edit, id: FactoryGirl.create(:user).url
      assigns(:user).should == user
    end

    it 'requires login' do
      logout
      get :edit, id: user.url
      response.should be_redirect
      flash[:error].should_not be_nil
    end
  end

  describe 'update' do
    before(:each) do
      login(user)
    end

    it 'only allows a user to edit their own profile' do
      put :update, id: FactoryGirl.create(:user).url, user: { first_name: 'Steve' }
      assigns(:user).should == user
    end

    context 'when successful' do
      it 'updates the user profile' do
        put :update, id: user.url, user: { first_name: 'Steve' }
        user.reload.first_name.should == 'Steve'
      end

      it 'redirects to the newly updated user profile' do
        put :update, id: user.url, user: { first_name: 'Steve' }
        response.should redirect_to user_path(user)
        flash[:success].should_not be_nil
      end
    end

    context 'when unsuccessful' do
      before(:each) do
        User.any_instance.stubs(:update_attributes).returns(false)
      end

      it 'does not update the user profile' do
        put :update, id: user.url, user: { first_name: 'Steve' }
        user.reload.first_name.should_not == 'Steve'
      end

      it 'redisplays the form with an error message' do
        put :update, id: user.url, user: { first_name: 'Steve' }
        response.should render_template('edit')
        flash[:error].should_not be_nil
      end
    end
  end

  describe 'settings' do
    it 'displays the edit user template' do
      login(user)
      get :settings
      response.should render_template('edit')
      assigns(:user).should == user
    end
  end
end
