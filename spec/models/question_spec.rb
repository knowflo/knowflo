require 'spec_helper'

describe Question do
  describe 'user' do
    it { should_not have_valid(:user_id).when(nil, '') }
    it { should have_valid(:user_id).when(FactoryGirl.create(:user).id) }

    context 'with a private group' do
      before(:each) do
        @group = FactoryGirl.create(:group, :privacy => 'private')
      end

      it 'should be allowed to post' do
        user = FactoryGirl.create(:membership, :group => @group).user
        FactoryGirl.create(:question, :user => user, :group => @group).should be_valid
      end

      it 'should not be allowed to post' do
        user = FactoryGirl.create(:user)
        question = FactoryGirl.build(:question, :user => user, :group => @group)
        question.should_not be_valid
        question.errors[:user_id].should include('is not authorized')
      end
    end
  end

  describe 'subject' do
    it { should_not have_valid(:subject).when(nil, '') }
    it { should have_valid(:subject).when('hello world') }
  end

  describe 'group' do
    it { should_not have_valid(:group_id).when(nil, '') }
    it { should have_valid(:group_id).when(FactoryGirl.create(:group).id) }
  end

  describe 'url' do
    before(:each) do
      @question = FactoryGirl.create(:question, :subject => 'Am I wrong?')
    end

    it 'should be created from the name' do
      @question.url.should == 'am-i-wrong'
    end

    it 'should be unique (scoped to the group)' do
      question = FactoryGirl.create(:question, :subject => 'Am I wrong?', :group => @question.group)
      question.url.should == 'am-i-wrong-1'
    end

    it { should_not have_valid(:url).when(nil, '') }
    it { should_not have_valid(:url).when('am-i-wrong') }
  end

  describe 'solution' do
    it 'should return the correct answer' do
      question = FactoryGirl.create(:question)
      answer = FactoryGirl.create(:answer, :question => question)
      answer.update_attribute(:solution, true)
      question.solution.should == answer
    end

    it 'should not have a solution' do
      FactoryGirl.create(:question).solution.should be_nil
    end
  end

  describe 'participants' do
    before(:each) do
      @question = FactoryGirl.create(:question)
      @answer1 = FactoryGirl.create(:answer, :question => @question)
      @answer2 = FactoryGirl.create(:answer, :question => @question)
      @comment1 = FactoryGirl.create(:comment, :answer => @answer1)
      @comment2 = FactoryGirl.create(:comment, :answer => @answer2, :user => @question.user)
    end

    it 'should include the user who asked the question' do
      @question.participants.should include(@question.user)
    end

    it 'should include users who answered' do
      @question.participants.should include(@answer1.user)
      @question.participants.should include(@answer2.user)
    end

    it 'should include users who commented' do
      @question.participants.should include(@comment1.user)
      @question.participants.should include(@comment2.user)
    end

    it 'should not include duplicates' do
      @question.participants.should == @question.participants.uniq
    end
  end

  describe 'visibility' do
    before(:each) do
      @public_question = FactoryGirl.create(:question) # public
      @inaccessible_private_group = FactoryGirl.create(:private_group_with_questions, :questions_count => 1)
      @inaccessible_question = @inaccessible_private_group.questions.first
      @private_group = FactoryGirl.create(:private_group_with_questions, :questions_count => 1)
      @private_question = @private_group.questions.first
      @user = @private_question.user
    end

    it 'should show only questions in public groups' do
      questions = Question.public_questions
      questions.size.should == 1
      questions.should include(@public_question)
    end

    it 'should show only questions in private groups' do
      questions = Question.private_questions(@user)
      questions.size.should == 1
      questions.should include(@private_question)
    end

    it 'should show all questions visible to the user' do
      questions = Question.visible(@user)
      questions.size.should == 2
      questions.should include(@public_question)
      questions.should include(@private_question)
      questions.should_not include(@inaccessible_question)
    end

    it 'should allow scope chaining' do
      FactoryGirl.create(:answer, :question => @public_question)
      Question.visible(@user).answered.should include @public_question
    end
  end
end
