class CommentsController < ApplicationController
  before_filter :login_required
  before_filter :find_group
  before_filter :find_comment, :except => [:create]
  before_filter :owner_required, :only => [:update]

  def create
    @answer = @group.answers.find(params[:answer_id] || (params[:comment] || {})[:answer_id])
    @question = @answer.question
    @comment = @answer.comments.build(params[:comment])
    @comment.user = current_user

    if @comment.save
      @membership = @group.memberships.find_or_create_by_user_id(current_user.id)
      @following = @question.followings.find_or_create_by_user_id(current_user.id)
      flash[:success] = "Thanks for commenting on that answer, chief."
      redirect_to(question_url(@question, :subdomain => @group))
    else
      flash[:error] = "Uh-oh, something went wrong. Please check the form for errors and try again."
      render :template => 'questions/show'
    end
  end

  def update
    if @comment.update_attributes(params[:comment])
      flash[:success] = "Your comment has been updated."
    else
      flash[:error] = "Sorry, we can't update that comment for you."
    end

    redirect_to(question_url(@comment.question, :subdomain => @group))
  end

  private

  def find_comment
    @comment = Comment.find(params[:id])
  end

  def owner_required
    return deny_user("You are not authorized to update that resource") unless @comment.user == current_user
  end
end
