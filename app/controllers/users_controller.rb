class UsersController < ApplicationController
  before_filter :find_optional_group
  before_filter :find_user, :only => [:show]

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    @user.ip_address = request.remote_ip
    if @user.save
      session[:user_id] = @user.id
      flash[:success] = "Thanks for signing up!"
      # TODO: we may want to redirect to a welcome screen for new users?
      redirect_back_or_default
    else
      flash[:error] = "Sorry, something went wrong. Please check the form for errors and try again."
      render :action => :new
    end
  end

  def show
  end

  private

  def find_user
    @user = User.find_by_url!(params[:id])
  end
end
