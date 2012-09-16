require 'spec_helper'

describe SessionsController do
  describe 'new' do
    it 'should render the login form' do
      get :new
      response.should render_template('new')
    end
  end

  describe 'create' do
    context 'using standard password auth' do
      before(:each) do
        @user = FactoryGirl.create(:user)
      end

      context 'when successful' do
        before(:each) do
          @params = { :user => { :email => @user.email, :password => 'password' } }
        end

        it 'should log the user in' do
          post :create, @params
          session[:user_id].should == @user.id
        end

        it 'should redirect to a stored location' do
          session[:return_url] = '/stuff'

          post :create, @params
          response.should redirect_to('/stuff')
        end

        it 'should redirect to root if no location is stored' do
          post :create, @params
          response.should redirect_to('/')
        end
      end

      context 'when unsuccessful' do
        before(:each) do
          @params = { :user => { :email => @user.email, :password => 'wrongpass' } }
        end

        it 'should not log the user in' do
          post :create, @params
          session[:user_id].should be_nil
        end

        it 'should re-display the login form' do
          post :create, @params
          flash[:error].should_not be_nil
          response.should render_template('new')
        end
      end
    end

    context 'using omniauth' do
      before(:each) do
        @user = FactoryGirl.create(:omniauth_user)
      end

      context 'with an existing user' do
        before(:each) do
          controller.stubs(:oauth_params).returns({
            'provider' => @user.auth_provider,
            'uid' => @user.auth_uid,
            'info' => { 'first_name' => @user.first_name,
                        'last_name'  => @user.last_name,
                        'email'      => @user.email }
          })
        end

        it "should sign an existing user in" do
          get :create
          session[:user_id].should == @user.id
        end

        it "should render the success view to close the auth popup" do
          post :create
          response.should render_template('success')
          flash[:success].should_not be_nil
        end

        it 'should set the url for the main window redirection (auth popup workflow)' do
          session[:return_url] = '/interesting-stuff'
          post :create
          assigns(:url).should == '/interesting-stuff'
        end
      end

      context "with a new user" do
        before(:each) do
          controller.stubs(:oauth_params).returns({
            'provider' => 'twitter',
            'uid' => '123450',
            'info' => { 'first_name' => 'jay',
                        'last_name' => 'garrick',
                        'email' => 'theflash00@jla.com' }
          })
        end

        it "should create a new user account" do
          expect {
            post :create
          }.to change(User, :count)

          session[:user_id].should_not be_nil
        end

        it "should render the success view to close the auth popup" do
          post :create
          response.should render_template('success')
          flash[:success].should_not be_nil
        end

        it 'should set the url for the main window redirection (auth popup workflow)' do
          session[:return_url] = '/interesting-stuff'
          post :create
          assigns(:url).should == '/interesting-stuff'
        end
      end

      context "for a user who is already logged in" do
        it "logs the user in with another pre-existing account"  do
          login(@user)

          another_user = FactoryGirl.create(:omniauth_user)
          controller.stubs(:oauth_params).returns({
            'provider' => another_user.auth_provider,
            'uid' => another_user.auth_uid,
            'info' => { 'first_name' => another_user.first_name,
                        'last_name'  => another_user.last_name,
                        'email'      => another_user.email }
          })

          expect {
            post :create
          }.to_not change(User, :count)

          session[:user_id].should == another_user.id
        end
      end

      it "should fail due to lack of data" do
        controller.stubs(:oauth_params).returns({
          'provider' => 'facebook'
        })

        expect {
          post :create
        }.to_not change(User, :count)

        response.should render_template('new')
        flash[:error].should_not be_blank
      end
    end
  end


  describe 'destroy' do
    before(:each) do
      login
    end

    it 'should log the user out' do
      delete :destroy
      session[:user_id].should be_nil
    end

    it 'should redirect to the root page' do
      delete :destroy
      flash[:success].should_not be_nil
      response.should redirect_to(root_url)
    end
  end
end
