class MembershipsController < ApplicationController
  before_filter :login_required, :except => [:accept]
  before_filter :find_group, :only => [:create, :destroy]
  before_filter :group_admin_required, :only => [:create, :destroy]

  def create
    @membership = @group.memberships.build(params[:membership])
    @membership.invited_by_user = current_user

    if @membership.save
      flash[:success] = "Your invitation was sent to #{@membership.invitation_email || @membership.user.email}."
      Notifier.group_invitation(@membership.id).deliver
    else
      flash[:error] = "Unable to send that invitation. Please check your information and try again."
    end

    redirect_to(group_root_url(@group))
  end

  def destroy
    @membership = @group.memberships.find_by_token!(params[:id])
    @membership.destroy

    flash[:success] = "We've removed #{@membership.user.name} from the group."
    redirect_to(group_root_url(@group))
  end

  def accept
    @group = Group.find_by_url!(params[:group_id] || subdomain)
    @membership = @group.memberships.find_by_token(params[:id])

    if @membership.nil? || @membership.try(:group_id) != @group.id
      flash[:error] = "You are not authorized to access this group."
      redirect_to(root_url, :subdomain => false)

    elsif @membership.try(:user_id).present?
      flash[:error] = "This invitation has already been used."
      redirect_to(root_url, :subdomain => false)

    elsif !logged_in?
      flash[:notice] = "Welcome to the #{@group.name} group! Please login with your account or fill out the (super quick) form below to get started..."
      session[:return_url] = request.fullpath
      redirect_to(new_user_url(:subdomain => @group))

    else
      @membership.update_attribute(:user, current_user)
      flash[:success] = "You've been added to the group and can now ask and answer questions."
      redirect_to(group_root_url(@group))
    end
  end

  private

  def group_admin_required
    if @group.user_role(current_user) != 'admin'
      flash[:error] = "You must be a group admin to do that."
      redirect_to(group_root_url(@group))
      return false
    end
  end
end
