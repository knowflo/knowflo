module AuthenticationSpecHelper
  def login(user = FactoryGirl.create(:user))
    session[:user_id] = user.id
    user
  end

  def logout
    session[:user_id] = nil
  end
end

RSpec::Matchers.define(:require_login) do
  match do |target|
    logout

    # Make the request
    target.call

    if request.params[:format] == 'json'
      response.should be_forbidden
    else
      flash[:error].should_not be_blank
      flash[:error].should =~ /logged in/
      response.should be_redirect
    end
  end

  failure_message_for_should do |actual|
    "expected action to require login"
  end
end

RSpec::Matchers.define(:require_admin) do
  match do |target|
    logout

    # Make the request
    target.call

    if request.params[:format] == 'json'
      response.should be_forbidden
    else
      flash[:error].should_not be_blank
      flash[:error].should =~ /admin/
      response.should be_redirect
    end
  end

  failure_message_for_should do |actual|
    "expected action to require admin"
  end
end
