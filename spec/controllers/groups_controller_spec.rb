require 'spec_helper'

describe GroupsController do
  before(:each) do
    @user = login
  end

  describe 'index' do
    before(:each) do
      @public_group = FactoryGirl.create(:group)
      @private_group = FactoryGirl.create(:private_group_with_questions)
      @user = @private_group.users.first
    end

    context 'user is not logged in' do
      it 'should render a list of public groups' do
        logout
        get :index
        response.should render_template('index')
        assigns(:groups).should == Group.public_groups
      end
    end

    context 'user is logged in' do
      it 'should render private groups if the user is logged in' do
        login(@user)
        get :index
        response.should render_template('index')
        assigns(:groups).should == @user.groups
      end
    end
  end

  describe 'show' do
    before(:each) do
      @group = FactoryGirl.create(:group)
      @params = { :id => @group }
    end

    context 'for a public group' do
      it 'should show a dashboard and message threads for the specified group' do
        get :show, @params
        response.should render_template('show')
        assigns(:questions).should == @group.questions.order('created_at DESC').page(1)
      end

      it 'should show the second page of results' do
        get :show, @params.merge(:page => 2)
        response.should render_template('show')
        assigns(:questions).should == @group.questions.order('created_at DESC').page(2)
      end
    end

    context 'for a private group' do
      before(:each) do
        @group.update_attribute(:privacy, 'private')
      end

      it 'should require login' do
        expect { get :show, @params }.to require_login
      end

      it 'should not be allowed unless the user belongs to the group' do
        login
        get :show, @params
        response.should be_redirect
        flash[:error].should_not be_nil
      end

      it 'should allow a group member to view messages' do
        user = login
        FactoryGirl.create(:membership, :group => @group, :user => user)

        get :show, @params
        response.should render_template('show')
        assigns(:questions).should == @group.questions.order('created_at DESC').page(1)
      end
    end
  end

  describe 'new' do
    it 'should require login' do
      expect { get :new }.to require_login
    end

    it 'should render the new group form' do
      get :new
      response.should render_template('new')
    end
  end

  describe 'create' do
    before(:each) do
      @params = { :group => { :name => 'Legion of Superheroes', :privacy => 'public' }}
    end

    it 'should require login' do
      expect { post :create, @params }.to require_login
    end

    it 'should create the group' do
      expect {
        post :create, @params
      }.to change(Group, :count)
    end

    it 'should make the user an administrator of the new group' do
      post :create, @params
      membership = Group.last.memberships.first
      membership.user.should == @user
      membership.role.should == 'admin'
    end

    it 'should redirect' do
      post :create, @params
      response.should redirect_to(group_root_url(Group.last))
      flash[:success].should_not be_blank
    end

    it 'should fail and re-render the page' do
      post :create, :group => { :name => '' }
      response.should render_template('new')
      flash[:error].should_not be_nil
    end
  end
end
