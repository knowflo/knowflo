class QuestionsController < ApplicationController
  before_filter :find_group,     :except => [:new]
  before_filter :find_question,  :only   => [:show, :update, :destroy, :follow, :unfollow]
  before_filter :login_required, :except => [:show]
  before_filter :owner_required, :only   => [:update, :destroy]

  def index
    redirect_to(group_root_url(@group))
  end

  def new
    find_group if params[:group_id] || subdomain

    @question = Question.new(:group => @group, :user => current_user)
  end

  def create
    @question = @group.questions.build(params[:question])
    @question.user = current_user
    if @question.save
      @membership = @group.memberships.find_or_create_by_user_id(current_user.id)
      @following = @question.followings.find_or_create_by_user_id(current_user.id)
      Notifier.new_question(@question.id, current_user.id).deliver
      flash[:success] = "Your question was added. Hopefully someone answers it soon."
      redirect_to(question_url(@question, :subdomain => @group))
    else
      flash[:error] = "Something went wrong. Please check the form for errors."
      render(:action => :new)
    end
  end

  def update
    if @question.update_attributes(params[:question])
      flash[:success] = "Your question has been updated."
    else
      flash[:error] = "Sorry, we can't update that question for you."
    end

    redirect_to(question_url(@question, :subdomain => @group))
  end

  def show
  end

  def destroy
    @question.destroy
    flash[:success] = "That question won't be bothering you any more."
    redirect_to(group_root_url(@group))
  end

  def follow
    @following = @question.followings.find_or_create_by_user_id(current_user.id)
    flash[:success] = "You are now following this question and will be notified when it's updated."
    redirect_to(question_url(@question, subdomain: @group))
  end

  def unfollow
    if @following = @question.followings.where(user_id: current_user.id).first
      @following.destroy
    end
    flash[:success] = "You will no longer receive notifications about this question."
    redirect_to(question_url(@question, subdomain: @group))
  end

  private

  def find_group
    if group_id = (params[:question] || {})[:group_id]
      @group = Group.find(group_id)
    else
      @group = Group.find_by_url!(params[:group_id] || subdomain)
    end

    if @group.private?
      return deny_user unless logged_in?
      return deny_user("You are not authorized to access this group") unless @group.users.include?(current_user)
    end
  end

  def find_question
    @question = Question.find(params[:id])
  end

  def owner_required
    return deny_user("You are not authorized to update that resource") unless @question.user == current_user
  end
end
