require 'spec_helper'

describe CommentsController do
  describe 'create' do
    before(:each) do
      @question = FactoryGirl.create(:question)
      @answer = FactoryGirl.create(:answer, :question => @question)
      @params = { :group_id => @answer.group, :answer_id => @answer, :comment => { :body => '+1 thanks' } }
    end

    it 'should require login' do
      expect { post :create, @params }.to require_login
    end

    it 'should require group membership for private groups' do
      @answer.group.update_attribute(:privacy, 'private')
      post :create, @params
      response.should redirect_to(login_path)
    end

    context 'when successful' do
      before(:each) do
        @user = login
      end

      it 'should create a new comment' do
        post :create, @params
        @answer.comments.count.should == 1
        @answer.comments.last.body.should == '+1 thanks'
        @answer.comments.last.user.should == @user
      end

      it 'should add the user to the group as a member' do
        post :create, @params
        @answer.group.users.should include(@user)
      end

      it 'should redirect' do
        post :create, @params
        flash[:success].should_not be_blank
        response.should redirect_to(question_url(@answer.question, :subdomain => @answer.group))
      end
    end

    context 'when unsuccessful' do
      before(:each) do
        @user = login
      end

      it 'should re-render the question (new answer) page with errors' do
        post :create, @params.except(:comment)
        flash[:error].should_not be_blank
        response.should render_template('questions/show')
      end
    end
  end

  describe 'update' do
    before(:each) do
      @question = FactoryGirl.create(:question)
      @answer = FactoryGirl.create(:answer, :question => @question)
      @comment = FactoryGirl.create(:comment, :answer => @answer)
      @params = { :group_id => @comment.group, :id => @comment, :comment => { :body => 'updated comment' } }
    end

    it 'should require login' do
      expect { put :update, @params }.to require_login
    end

    it 'should require the user that created the comment' do
      login
      put :update, @params
      flash[:error].should_not be_blank
      response.should redirect_to(login_path)
    end

    context 'when the current user created the comment' do
      before(:each) do
        login(@comment.user)
      end

      it 'should redirect on success' do
        put :update, @params
        flash[:error].should be_blank
        response.should redirect_to(question_url(@comment.question, :subdomain => @comment.group))
      end

      it 'should update the resource' do
        put :update, @params
        @comment.reload.body.should == 'updated comment'
      end
    end
  end
end
