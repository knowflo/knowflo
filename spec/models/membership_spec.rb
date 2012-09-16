require 'spec_helper'

describe Membership do
  describe 'group' do
    it { should have_valid(:group_id).when(FactoryGirl.create(:group).id) }
    it { should_not have_valid(:group_id).when(nil, '') }
  end

  describe 'role' do
    it { should have_valid(:role).when('admin') }
    it { should_not have_valid(:role).when('admiral') }

    it 'should default to member' do
      FactoryGirl.create(:membership).role.should == 'member'
    end
  end

  describe 'token' do
    it 'is created automatically' do
      FactoryGirl.create(:membership).token.should_not be_nil
    end
  end

  describe 'invitation_email' do
    it { should have_valid(:invitation_email).when('keith@voltron.com') }
    it { should_not have_valid(:invitation_email).when('thisisnotanemailaddress') }
  end

  describe 'check recipient' do
    it 'should be valid if a user is specified' do
      FactoryGirl.build(:membership, :user => FactoryGirl.create(:user)).should be_valid
    end

    it 'should be valid if an email is specified' do
      FactoryGirl.build(:membership, :user => nil, :invitation_email => 'memberships@zerosum.org').should be_valid
    end

    it 'should be invalid if neither a user or an email is specified' do
      membership = FactoryGirl.build(:membership, :invitation_email => nil, :user => nil)
      membership.should_not be_valid
      membership.errors[:invitation_email].should_not be_blank
    end
  end
end
