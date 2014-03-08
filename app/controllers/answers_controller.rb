class AnswersController < ApplicationController
  before_filter :login_required
  before_filter :find_group
  before_filter :find_answer, :except => [:create]
  before_filter :owner_required, :only => [:update]

  def create
    @question = @group.questions.find(params[:question_id] || (params[:answer] || {})[:question_id])
    @answer = @question.answers.build(params[:answer])
    @answer.user = current_user

    if @answer.save
      @membership = @group.memberships.find_or_create_by_user_id(current_user.id)
      @following = @question.followings.find_or_create_by_user_id(current_user.id)
      flash[:success] = "Damn you're smart. And good looking, too. Thanks for adding your answer!"
      redirect_to(question_url(@question, :subdomain => @group))
    else
      flash[:error] = "Uh-oh, something went wrong. Please check the form for errors and try again."
      render :template => 'questions/show'
    end
  end

  def update
    if @answer.update_attributes(params[:answer])
      flash[:success] = "Your answer has been updated."
    else
      flash[:error] = "Sorry, we can't update that answer for you."
    end

    redirect_to(question_url(@answer.question, :subdomain => @group))
  end

  def vote
    value = params[:value].present? ? params[:value] : 1
    @vote = Vote.new(:answer => @answer, :user => current_user, :value => value)
    @vote.save

    respond_to do |format|
      format.html do
        redirect_to(question_url(@answer.question, :subdomain => @group))
      end
      format.json { render :json => @answer.to_json }
    end
  end

  def mark
    return deny_user("Only the question owner can mark a solution as correct") unless @answer.question.user == current_user

    @answer.update_attribute(:solution, true)
    flash[:success] = "We're glad that you found your answer."
    redirect_to(question_url(@answer.question, :subdomain => @group))
  end

  private

  def find_answer
    @answer = Answer.find(params[:id])
  end

  def owner_required
    return deny_user("You are not authorized to update that resource") unless @answer.user == current_user
  end
end
