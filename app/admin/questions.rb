SimpleAdmin.register :question do
  index do
    attributes do
      clear
      attribute :subject
      attribute :group_id do |p|
        link_to(p.group, simple_admin_group_path(p.group))
      end
      attribute :user_id do |p|
        link_to(p.user, simple_admin_user_path(p.user))
      end
      attribute :created_at
      attribute :updated_at
    end

    filters :only => [:subject, :body, :group_id, :url, :created_at, :updated_at]
  end

  show do
    attributes do
      attribute :group_id do |p|
        link_to(p.group, simple_admin_group_path(p.group))
      end
      attribute :user_id do |p|
        link_to(p.user, simple_admin_user_path(p.user))
      end
      attribute :body do |p|
        simple_format(p.body)
      end
    end
  end

  form do
  end
end
