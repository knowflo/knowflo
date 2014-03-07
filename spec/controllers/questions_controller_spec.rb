require 'spec_helper'

describe QuestionsController do
  describe 'index' do
    it 'should redirect to the group page' do
      group = FactoryGirl.create(:group)
      login

      get :index, :group_id => group
      response.should redirect_to(group_root_url(group))
    end
  end

  describe 'new' do
    before(:each) do
      @group = FactoryGirl.create(:group)
      @params = { :group_id => @group, :question => FactoryGirl.attributes_for(:question, :group => @group) }
      login
    end

    it 'should require login' do
      expect { get :new, :group_id => @group }.to require_login
    end

    it 'should render the new question page' do
      get :new, :group_id => @group
      response.should render_template('questions/new')
      assigns(:question).should_not be_blank
    end
  end

  describe 'create' do
    before(:each) do
      @group = FactoryGirl.create(:group)
      @params = { :group_id => @group, :question => FactoryGirl.attributes_for(:question, :group => @group) }
      login(@user = FactoryGirl.create(:user))
    end

    it 'should require login' do
      expect { post :create, @params }.to require_login
    end

    it 'should require group membership for private groups' do
      @group.update_attribute(:privacy, 'private')
      post :create, @params
      response.should redirect_to(login_path)
    end

    context 'when successful' do
      it 'should create a new question' do
        expect {
          post :create, @params
        }.to change(Question, :count)
      end

      it 'should add the user to the group as a member' do
        post :create, @params
        @group.users.should include(@user)
      end

      it 'should redirect' do
        post :create, @params
        flash[:success].should_not be_blank
        response.should redirect_to(question_url(Question.last, :subdomain => @group))
      end
    end

    context 'when unsuccessful' do
      it 'should re-render the page with errors' do
        post :create, :group_id => @group, :question => {}
        flash[:error].should_not be_blank
        response.should render_template('questions/new')
      end
    end
  end

  describe 'update' do
    before(:each) do
      @question = FactoryGirl.create(:question)
      @params = { :group_id => @question.group, :id => @question, :question => { :body => 'updated question' } }
    end

    it 'should require login' do
      expect { put :update, @params }.to require_login
    end

    it 'should require the user that created the question' do
      login
      put :update, @params
      flash[:error].should_not be_blank
      response.should redirect_to(login_path)
    end

    context 'when the current user created the question' do
      before(:each) do
        login(@question.user)
      end

      it 'should redirect on success' do
        put :update, @params
        flash[:error].should be_blank
        response.should redirect_to(question_url(@question, :subdomain => @question.group))
      end

      it 'should update the resource' do
        put :update, @params
        @question.reload.body.should == 'updated question'
      end
    end
  end

  describe 'show' do
    before(:each) do
      @question = FactoryGirl.create(:question)
      @params = { :group_id => @question.group, :id => @question}
    end

    context 'for a public group' do
      it 'should show the question for the specified group' do
        get :show, @params
        response.should render_template('show')
        assigns(:question).should == @question
      end
    end

    context 'for a private group' do
      before(:each) do
        @group = @question.group
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

      it 'should allow a group member to view questions' do
        user = login
        FactoryGirl.create(:membership, :group => @group, :user => user)

        get :show, @params
        response.should render_template('show')
        assigns(:question).should == @question
      end
    end
  end

  describe 'destroy' do
    before(:each) do
      @question = FactoryGirl.create(:question)
      @params = { :group_id => @question.group, :id => @question }
    end

    it 'should require login' do
      expect { delete :destroy, @params }.to require_login
    end

    it 'should require the user that created the question' do
      login
      delete :destroy, @params
      flash[:error].should_not be_blank
      response.should redirect_to(login_path)
    end

    it 'should remove the post and redirect' do
      login(@question.user)
      delete :destroy, @params
      flash[:success].should_not be_blank
      response.should redirect_to(group_root_url(@question.group))
    end
  end
end
