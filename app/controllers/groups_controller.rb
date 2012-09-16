class GroupsController < ApplicationController
  before_filter :login_required, :only => [:new, :create]
  before_filter :find_group, :only => [:show]

  def index
    @groups = logged_in? ? current_user.groups : Group.public_groups
  end

  def show
    # TODO: support a default group for main site (news?)
    @questions = @group.questions.order('created_at DESC').page(params[:page])
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(params[:group])
    if @group.save
      @membership = current_user.memberships.create(:role => 'admin', :group => @group)
      flash[:success] = "Your group was created and you're now an admin. Bet you feel pretty important, eh?"
      redirect_to(group_root_url(@group))
    else
      flash[:error] = "Something went terribly wrong. Please check the form for errors."
      render :action => 'new'
    end
  end

  private

  def find_group
    @group = Group.find_by_url!(params[:id] || params[:group_id] || subdomain)
    if @group.private?
      return deny_user unless logged_in?
      return deny_user("You are not authorized to access this group") unless @group.users.include?(current_user)
    end
  end
end
