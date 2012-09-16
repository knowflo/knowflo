require 'spec_helper'

describe Vote do
  describe 'user' do
    it { should_not have_valid(:user_id).when(nil, '') }
    it { should have_valid(:user_id).when(FactoryGirl.create(:user).id) }
  end

  describe 'answer' do
    it { should_not have_valid(:answer_id).when(nil, '') }
    it { should have_valid(:answer_id).when(FactoryGirl.create(:answer).id) }
  end

  describe 'value' do
    it { should have_valid(:value).when(-1, 1) }
    it { should_not have_valid(:value).when(-2, 2, 0, 10000) }

    it 'should be used to update answer points cache after save' do
      answer = FactoryGirl.create(:answer)
      FactoryGirl.create(:vote, :answer => answer, :value => 1)
      answer.reload.points_cache.should == 2 # includes owner vote
    end
  end

  describe 'uniqueness' do
    before(:each) do
      @answer = FactoryGirl.create(:answer)
    end

    it 'should overwrite (not append to) older votes' do
      vote = FactoryGirl.create(:vote, :answer => @answer, :value => -1)
      user = vote.user

      expect {
        FactoryGirl.create(:vote, :value => 1, :user => user, :answer => @answer)
      }.to_not change(Vote, :count)

      Vote.last.value.should == 1
    end

    it 'should not replace votes from other users' do
      expect {
        vote = FactoryGirl.create(:vote, :answer => @answer, :value => 1)
        FactoryGirl.create(:vote, :answer => @answer, :value => 1)
      }.to change(Vote, :count).by(2)
    end
  end
end
