require 'spec_helper'

describe AnswersController do
  describe 'create' do
    before(:each) do
      @question = FactoryGirl.create(:question)
      @params = { :group_id => @question.group, :question_id => @question, :answer => { :body => '42.' } }
    end

    it 'should require login' do
      expect { post :create, @params }.to require_login
    end

    it 'should require group membership for private groups' do
      @question.group.update_attribute(:privacy, 'private')
      post :create, @params
      response.should redirect_to(login_path)
    end

    context 'when successful' do
      before(:each) do
        @user = login
      end

      it 'should create a new answer' do
        post :create, @params
        @question.answers.count.should == 1
        @question.answers.last.body.should == '42.'
        @question.answers.last.user.should == @user
      end

      it 'should add the user to the group as a member' do
        post :create, @params
        @question.group.users.should include(@user)
      end

      it 'adds the user to the list of users following the question' do
        post :create, @params
        @question.following_users.should include(@user)
      end

      it 'should redirect' do
        post :create, @params
        flash[:success].should_not be_blank
        response.should redirect_to(question_url(@question, :subdomain => @question.group))
      end
    end

    context 'when unsuccessful' do
      before(:each) do
        @user = login
      end

      it 'should re-render the question (new answer) page with errors' do
        post :create, @params.except(:answer)
        flash[:error].should_not be_blank
        response.should render_template('questions/show')
      end
    end
  end

  describe 'update' do
    before(:each) do
      @answer = FactoryGirl.create(:answer)
      @params = { :group_id => @answer.group, :id => @answer, :answer => { :body => 'updated answer' } }
    end

    it 'should require login' do
      expect { put :update, @params }.to require_login
    end

    it 'should require the user that created the answer' do
      login
      put :update, @params
      flash[:error].should_not be_blank
      response.should redirect_to(login_path)
    end

    context 'when the current user created the answer' do
      before(:each) do
        login(@answer.user)
      end

      it 'should redirect on success' do
        put :update, @params
        flash[:error].should be_blank
        response.should redirect_to(question_url(@answer.question, :subdomain => @answer.group))
      end

      it 'should update the resource' do
        put :update, @params
        @answer.reload.body.should == 'updated answer'
      end
    end
  end

  describe 'mark' do
    before(:each) do
      @question = FactoryGirl.create(:question)
      @answer = FactoryGirl.create(:answer, :question => @question)
      @params = { :group_id => @answer.group, :id => @answer }
    end

    it 'should require login' do
      expect { post :mark, @params }.to require_login
    end

    it 'should require the question owner' do
      login
      post :mark, @params
      flash[:error].should == 'Only the question owner can mark a solution as correct'
      response.should redirect_to(login_path)
    end

    context 'when logged in as the question owner' do
      before(:each) do
        login(@question.user)
      end

      it 'should mark the answer as the solution' do
        post :mark, @params
        @answer.reload.should be_solution
      end

      it 'should redirect on success' do
        post :mark, @params
        flash[:success].should_not be_blank
        response.should redirect_to(question_url(@answer.question, :subdomain => @answer.group))
      end

      it 'should un-mark other answers' do
        previous_answer = FactoryGirl.create(:answer, :question => @answer.question, :user => @answer.question.user, :solution => true)
        post :mark, @params
        previous_answer.reload.should_not be_solution
      end
    end
  end

  describe 'vote' do
    before(:each) do
      @answer = FactoryGirl.create(:answer)
      @params = { :group_id => @answer.group, :id => @answer, :value => 1 }
      login(@user = FactoryGirl.create(:user))
    end

    it 'should require login' do
      expect { post :vote, @params }.to require_login
    end

    it 'should record the user upvote' do
      expect {
        post :vote, @params
      }.to change(Vote, :count)

      @answer.votes.last.user.should == @user
      @answer.votes.last.value.should == 1
    end

    it 'should record the user downvote' do
      expect {
        post :vote, @params.merge(:value => -1)
      }.to change(Vote, :count)

      @answer.votes.last.user.should == @user
      @answer.votes.last.value.should == -1
    end

    it 'should redirect on success' do
      post :vote, @params
      response.should redirect_to(question_url(@answer.question, :subdomain => @answer.group))
    end
  end
end
