class UsersController < ApplicationController
  before_filter :login_required, only: [:settings, :edit, :update]
  before_filter :find_optional_group
  before_filter :find_user, only: [:show]
  before_filter :find_current_user, only: [:settings, :edit, :update]

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

  def edit
  end

  def settings
    render :edit
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Your settings have been updated."
      redirect_to(user_path(current_user))
    else
      flash[:error] = "Something went wrong. Please check the form and try again."
      render :edit
    end
  end

  private

  def find_user
    @user = User.find_by_url!(params[:id])
  end

  def find_current_user
    @user = current_user
  end
end
