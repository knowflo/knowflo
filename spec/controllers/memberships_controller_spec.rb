require 'spec_helper'

describe MembershipsController do
  describe 'create' do
    before(:each) do
      @group = FactoryGirl.create(:private_group_with_questions)
      @user = @group.users.first

      login(@user)
      @params = { :group_id => @group, :membership => { :invitation_email => 'recipient@zerosum.org' }}
    end

    it 'should require login' do
      expect { post :create, @params }.to require_login
    end

    it 'should only allow a group admin to send an invitation' do
      user = FactoryGirl.create(:membership, :group => @group).user
      login(user)
      post :create, @params
      flash[:error].should_not be_blank
      response.should redirect_to(group_root_url(@group))
    end

    it 'should redirect if the invitation is created successfully' do
      post :create, @params
      flash[:success].should_not be_blank
      response.should redirect_to(group_root_url(@group))
    end

    it 'should send an invitation email' do
      expect {
        post :create, @params
      }.to change(ActionMailer::Base.deliveries, :count)
    end
  end

  describe 'destroy' do
    before(:each) do
      @group = FactoryGirl.create(:private_group_with_questions)
      @user = @group.users.first

      login(@user)
      @membership = FactoryGirl.create(:membership, :group => @group)
      @params = { :group_id => @group, :id => @membership }
    end

    it 'should require login' do
      expect { delete :destroy, @params }.to require_login
    end

    it 'should only allow a group admin to remove a user' do
      user = FactoryGirl.create(:membership, :group => @group).user
      login(user)
      delete :destroy, @params
      flash[:error].should_not be_blank
      response.should redirect_to(group_root_url(@group))
    end

    it 'should remove the user from the group' do
      expect {
        delete :destroy, @params
      }.to change(Membership, :count).by(-1)
    end

    it 'should redirect after removing the user' do
      delete :destroy, @params
      flash[:success].should_not be_blank
      response.should redirect_to(group_root_url(@group))
    end
  end

  describe 'accept' do
    before(:each) do
      @group = FactoryGirl.create(:private_group_with_questions)
      @user = FactoryGirl.create(:user)

      login(@user)
      @membership = FactoryGirl.create(:invitation, :group => @group)
      @params = { :group_id => @group, :id => @membership }
    end

    it 'should make sure the token matches the group' do
      get :accept, @params.merge(:id => 'abcdefg')
      flash[:error].should_not be_blank
      response.should redirect_to(root_url)
    end

    it 'should not allow a token to be used more than once' do
      @membership.update_attribute(:user, FactoryGirl.create(:user))
      get :accept, @params
      flash[:error].should_not be_blank
      response.should redirect_to(root_url)
    end

    it 'should redirect the user and prompt them to login' do
      logout
      get :accept, @params
      session[:return_url].should_not be_blank
      flash[:notice].should_not be_nil
      response.should redirect_to(new_user_url(:subdomain => @group))
    end

    it 'should set the recipient user' do
      get :accept, @params
      @membership.reload.user.should == @user
    end

    it 'should redirect once the invitation is accepted' do
      get :accept, @params
      flash[:success].should_not be_blank
      response.should redirect_to(group_root_url(@group))
    end
  end
end
