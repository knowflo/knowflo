require 'spec_helper'

describe Comment do
  describe 'user' do
    it { should_not have_valid(:user_id).when(nil, '') }
    it { should have_valid(:user_id).when(FactoryGirl.create(:user).id) }

    context 'with a private group' do
      before(:each) do
        @group = FactoryGirl.create(:group, :privacy => 'private')
        question_user = FactoryGirl.create(:membership, :group => @group).user
        @question = FactoryGirl.create(:question, :group => @group, :user => question_user)
        answer_user = FactoryGirl.create(:membership, :group => @group).user
        @answer = FactoryGirl.create(:answer, :question => @question, :user => answer_user)
      end

      it 'should be allowed to post' do
        user = FactoryGirl.create(:membership, :group => @group).user
        FactoryGirl.create(:comment, :user => user, :answer => @answer).should be_valid
      end

      it 'should not be allowed to post' do
        user = FactoryGirl.create(:user)
        comment = FactoryGirl.build(:comment, :user => user, :answer => @answer)
        comment.should_not be_valid
        comment.errors[:user_id].should include('is not authorized')
      end
    end
  end

  describe 'answer' do
    it { should_not have_valid(:answer_id).when(nil, '') }
    it { should have_valid(:answer_id).when(FactoryGirl.create(:answer).id) }
  end

  describe 'body' do
    it { should_not have_valid(:body).when(nil, '') }
    it { should have_valid(:body).when('answer') }
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
end
