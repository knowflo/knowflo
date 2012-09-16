class SessionsController < ApplicationController
  before_filter :find_optional_group, :only => [:new]

  def new
  end

  def create
    if user = User.authenticate(passw_params[:email], passw_params[:password])
      success(user)
    elsif oauth_params.present?
      if user = User.find_by_auth_provider_and_auth_uid(oauth_params['provider'], oauth_params['uid'])
        success(user)
      else
        user = User.create_with_omniauth!(oauth_params)
        # TODO: we may want to redirect to a welcome screen for new users?
        success(user, 'Thanks for signing up!')
      end
    else
      flash[:error] = "Sorry, we couldn't log you in with those credentials. Want to give it another shot?"
      render :action => :new
    end

  rescue ActiveRecord::RecordInvalid => e
    # omniauth fail
    flash[:error] = "Sorry, we couldn't log you in with those credentials. Want to give it another shot?"
    render :action => :new
  end

  def failure
    redirect_to(new_session_path, :alert => 'Authentication failed. Please try again.')
  end

  def destroy
    logout
    flash[:success] = "See you later!"
    redirect_to(root_url)
  end

  private

  def oauth_params
    request.env['omniauth.auth'] || {}
  end

  def passw_params
    params[:user] || {}
  end

  def success(user, message = 'Welcome back!')
    user.update_attribute(:ip_address, request.remote_ip)
    session[:user_id] = user.id
    flash[:success] = message

    if oauth_params.present?
      # render custom view to close auth popup and redirect
      @url = redirect_location
      render :action => :success, :layout => false
    else
      redirect_back_or_default
    end
  end

  def redirect_location
    return session.delete(:return_url) if session[:return_url]

    if request.env['omniauth.origin']
      ['signup', 'login'].each do |pattern|
        return root_path if request.env['omniauth.origin'].match(/#{pattern}/)
      end

      request.env['omniauth.origin']
    else
      nil
    end
  end
end
