class ApplicationController < ActionController::Base
  include UrlHelper

  protect_from_forgery

  helper_method :current_user, :logged_in?
  helper :all

  protected

  def redirect_back_or_default
    redirect_to(session.delete(:return_url) || '/')
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
    @current_user ||= User.find_by_remember_token(cookies[:remember_token]) if cookies[:remember_token]
    @current_user
  end

  def current_user_name
    current_user.try(:username)
  end

  def logout
    begin
      current_user.update_attribute(:remember_token, nil)
    rescue # evil but whatevs
    end

    cookies.delete(:remember_token)
    session[:user_id] = nil
    session[:facebook_session] = nil
    @current_user = nil
  end

  def logged_in?
    !!current_user
  end

  def login_required
    deny_user unless logged_in?
  end

  def admin_required
    deny_user("Sorry, you must be an admin to do that", "/login") unless logged_in? && current_user.admin?
  end

  def deny_user(message=nil, location=login_path)
    session[:return_url] = request.fullpath
    respond_to do |format|
      format.json { render(:status => 403, :nothing => true) }
      format.html do
        flash[:error] = message || "Sorry, you must be logged in to do that"
        redirect_to(location)
      end
    end

    return false
  end

  def subdomain
    value = request.subdomain
    if value.present? && !Group::FORBIDDEN_SLUGS.include?(value)
      value
    else
      nil
    end
  end

  def find_group
    @group = Group.find_by_url!(params[:group_id] || subdomain)
    if @group.private?
      return deny_user unless logged_in?
      return deny_user("You are not authorized to access this group") unless @group.users.include?(current_user)
    end
  end

  def find_optional_group
    if @group = Group.find_by_url(params[:group_id] || subdomain)
      if @group.private?
        @group = nil unless logged_in? && @group.users.include?(current_user)
      end
    end
  end
end
