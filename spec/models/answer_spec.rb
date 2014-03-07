require 'spec_helper'

describe Answer do
  describe 'user' do
    it { should_not have_valid(:user_id).when(nil, '') }
    it { should have_valid(:user_id).when(FactoryGirl.create(:user).id) }

    context 'with a private group' do
      before(:each) do
        @group = FactoryGirl.create(:group, :privacy => 'private')
        question_user = FactoryGirl.create(:membership, :group => @group).user
        @question = FactoryGirl.create(:question, :group => @group, :user => question_user)
      end

      it 'should be allowed to post' do
        user = FactoryGirl.create(:membership, :group => @group).user
        FactoryGirl.create(:answer, :user => user, :question => @question).should be_valid
      end

      it 'should not be allowed to post' do
        user = FactoryGirl.create(:user)
        answer = FactoryGirl.build(:answer, :user => user, :question => @question)
        answer.should_not be_valid
        answer.errors[:user_id].should include('is not authorized')
      end
    end
  end

  describe 'question' do
    it { should_not have_valid(:question_id).when(nil, '') }
    it { should have_valid(:question_id).when(FactoryGirl.create(:question).id) }
  end

  describe 'body' do
    it { should_not have_valid(:body).when(nil, '') }
    it { should have_valid(:body).when('answer') }
  end

  describe 'solution' do
    before(:each) do
      @question = FactoryGirl.create(:question)
    end

    it 'cannot be assigned by a random user at creation time' do
      @answer = FactoryGirl.build(:answer, :question => @question, :solution => true)
      @answer.should_not be_valid
      @answer.errors[:solution].should include('cannot be set')
    end

    it 'can be assigned by the question author at creation time' do
      @answer = FactoryGirl.build(:answer, :question => @question, :user => @question.user, :solution => true)
      @answer.should be_valid
    end

    it 'cannot be mass-assigned' do
      @answer = FactoryGirl.create(:answer, :question => @question, :user => @question.user)

      expect {
        @answer.update_attributes(:solution => true).should be_false
      }.to raise_error(ActiveModel::MassAssignmentSecurity::Error)

      @answer.solution = true
      @answer.save.should be_true
    end

    it 'should prevent more than one answer being marked as a solution' do
      @old_solution = FactoryGirl.create(:answer, :question => @question, :user => @question.user, :solution => true)
      @new_solution = FactoryGirl.create(:answer, :question => @question)
      @new_solution.solution = true
      @new_solution.save
      @question.answers.solutions.should == [@new_solution]
    end
  end

  describe 'short_text' do
    it 'should be the entire body for a short comment' do
      comment = FactoryGirl.create(:comment, :body => 'Thanks!')
      comment.short_text.should == 'Thanks!'
    end

    it 'should be truncated for a long comment' do
      comment = FactoryGirl.create(:comment, :body => "No I don't stop it. I want my baby. There is no bathroom. Wrong. Feel how soft my skin is. Only pain. That's for sleeping with my wife. In a damn minivan. Hello cutie pie. One of us is in deep trouble. Crush your enemies, to see them driven before you, and to hear the lamentations of their women.. Shutup.")
      comment.short_text.size.should == 40
      comment.short_text.should match(/.*\.\.\.$/)
    end
  end

  describe 'points' do
    before(:each) do
      @answer = FactoryGirl.create(:answer) # includes one vote from answer owner
      4.times { FactoryGirl.create(:vote, :answer => @answer, :value => 1) }
      2.times { FactoryGirl.create(:vote, :answer => @answer, :value => -1) }
    end

    it 'should include an upvote for answer creator' do
      FactoryGirl.create(:answer).points.should == 1
    end

    it 'should be the sum of all the vote values' do
      @answer.points.should == 3
    end

    it 'should cache the points value' do
      FactoryGirl.create(:vote, :answer => @answer, :value => 1)
      @answer.update_points_cache.should be_true
      @answer.read_attribute(:points_cache).should == 4
    end
  end

  describe 'vote_for' do
    before(:each) do
      @answer = FactoryGirl.create(:answer)
      @user = FactoryGirl.create(:user)
    end

    it 'should always get a point automatically from the answer owner' do
      @answer.vote_for(@answer.user).should == 1
    end

    it 'should be 0 if the user has not voted' do
      @answer.vote_for(@user).should == 0
    end

    it 'should be -1 if the user downvoted' do
      FactoryGirl.create(:vote, :answer => @answer, :user => @user, :value => -1)
      @answer.vote_for(@user).should == -1
    end

    it 'should be 1 if the user upvoted' do
      FactoryGirl.create(:vote, :answer => @answer, :user => @user, :value => 1)
      @answer.vote_for(@user).should == 1
    end
  end
end
