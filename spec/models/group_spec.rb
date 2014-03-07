require 'spec_helper'

describe Group do
  describe 'name' do
    it { should have_valid(:name).when('Awesome Sauce') }
    it { should_not have_valid(:name).when(nil, '') }
  end

  describe 'privacy' do
    it { should have_valid(:privacy).when('private') }
    it { should_not have_valid(:privacy).when('jerks') }

    it 'should default to public' do
      FactoryGirl.create(:group).privacy.should == 'public'
    end

    it 'should be private' do
      FactoryGirl.create(:group, :privacy => 'private').should be_private
    end

    it 'should be public' do
      FactoryGirl.create(:group, :privacy => 'public').should be_public
    end

    it 'should have scopes for private and public' do
      private_group = FactoryGirl.create(:group, :privacy => 'private')
      public_group = FactoryGirl.create(:group, :privacy => 'public')
      Group.private_groups.should == [private_group]
      Group.public_groups.should == [public_group]
    end

    it 'should be visible if public' do
      FactoryGirl.create(:group, :privacy => 'public').visible_to(FactoryGirl.create(:user)).should be_true
    end

    it 'should be visible only if a user belongs to a private group' do
      group = FactoryGirl.create(:group, :privacy => 'private')
      user = FactoryGirl.create(:user)
      group.visible_to(user).should be_false
      FactoryGirl.create(:membership, :group => group, :user => user)
      group.visible_to(user).should be_true
    end
  end

  describe 'url' do
    before(:each) do
      @group = FactoryGirl.create(:group, :name => 'Seriuz Bizniz')
    end

    it 'should be created from the name' do
      @group.url.should == 'seriuz-bizniz'
    end

    it 'should be unique' do
      group = FactoryGirl.create(:group, :name => 'Seriuz Bizniz')
      group.url.should == 'seriuz-bizniz-1'
    end

    it { should_not have_valid(:url).when(nil, '') }
    it { should_not have_valid(:url).when('seriuz-bizniz', 'www') }
  end

  describe 'user_role' do
    it 'should be a member' do
      group = FactoryGirl.create(:private_group_with_questions)
      user = group.users.first
      group.user_role(user).should == 'admin'
    end

    it 'should not be nil' do
      FactoryGirl.create(:group).user_role(FactoryGirl.create(:user)).should be_nil
    end
  end
end
