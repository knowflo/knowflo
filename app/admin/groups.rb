SimpleAdmin.register :group do
  before :only => [:show, :edit, :update, :destroy] do
    @resource = Group.find_by_url!(params[:id])
  end

  index do
    attributes do
      clear
      attribute :name
      attribute :privacy
      attribute :url
      attribute :created_at
      attribute :updated_at
    end

    filters :only => [:name, :privacy, :url]
  end

  show do
    attributes
  end

  form do
    attributes do
      attribute :privacy, :as => :select, :collection => Group::PRIVACY_OPTIONS
    end
  end
end
