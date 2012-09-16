SimpleAdmin.register :vote do
  index do
    attributes do
      clear
      attribute :answer_id do |p|
        link_to(p.answer, simple_admin_answer_path(p.answer))
      end
      attribute :user_id do |p|
        link_to(p.user, simple_admin_user_path(p.user))
      end
      attribute :value
      attribute :created_at
      attribute :updated_at
    end

    filters :only => [:value, :created_at, :updated_at]
  end

  show do
    attributes do
      attribute :answer_id do |p|
        link_to(p.answer, simple_admin_answer_path(p.answer))
      end
      attribute :user_id do |p|
        link_to(p.user, simple_admin_user_path(p.user))
      end
    end
  end

  form do
  end
end
