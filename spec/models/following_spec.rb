require 'spec_helper'

describe Following do
  describe 'user_id' do
    it { should_not have_valid(:user_id).when(nil, '') }
  end

  describe 'question_id' do
    it { should_not have_valid(:question_id).when(nil, '') }
  end
end
