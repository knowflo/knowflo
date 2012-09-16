SimpleAdmin.register :user do
  before :only => [:show, :edit, :update, :destroy] do
    @resource = User.find_by_url!(params[:id])
  end

  index do
    attributes do
      clear
      attribute :email
      attribute :first_name
      attribute :last_name
      attribute :auth_provider
      attribute :admin
      attribute :url
      attribute :created_at
      attribute :updated_at
    end

    filters :only => [:email, :first_name, :last_name, :auth_provider, :auth_uid, :admin, :url]
  end

  show do
    attributes :except => [:password_digest, :remember_token] do
      attribute :avatar_url do |user|
        image_tag(user.avatar_url, :width => 50, :height => 50) if user.avatar_url.present?
      end
    end
  end

  form do
    attributes :except => [:password_digest, :remember_token, :admin] do
      attribute :password
      attribute :password_confirmation
    end
  end
end
