SimpleAdmin.register :membership do
  before :only => [:show, :edit, :update, :destroy] do
    @resource = Membership.find_by_token!(params[:id])
  end

  index do
    attributes do
      clear
      attribute :group_id do |m|
        link_to(m.group, simple_admin_group_path(m.group))
      end
      attribute :user_id do |m|
        link_to(m.user, simple_admin_user_path(m.user)) if m.user
      end
      attribute :role
      attribute :invited_by_user_id do |m|
        link_to(m.invited_by_user, simple_admin_user_path(m.invited_by_user)) if m.invited_by_user
      end
      attribute :invitation_email
      attribute :created_at
      attribute :updated_at
    end

    filters :only => [:role, :invitation_email]
  end

  show do
    attributes do
      attribute :group_id do |m|
        link_to(m.group, simple_admin_group_path(m.group))
      end
      attribute :user_id do |m|
        link_to(m.user, simple_admin_user_path(m.user)) if m.user
      end
      attribute :invited_by_user_id do |m|
        link_to(m.invited_by_user, simple_admin_user_path(m.invited_by_user)) if m.invited_by_user
      end
    end
  end

  form do
    attributes do
      attribute :role, :as => :select, :collection => Membership::ROLE_OPTIONS
    end
  end
end
