SimpleAdmin.register :comment do
  index do
    attributes do
      clear
      attribute :body do |p|
        p.short_text
      end
      attribute :answer_id do |p|
        link_to(p.answer, simple_admin_answer_path(p.answer))
      end
      attribute :user_id do |p|
        link_to(p.user, simple_admin_user_path(p.user))
      end
      attribute :created_at
      attribute :updated_at
    end

    filters :only => [:body, :created_at, :updated_at]
  end

  show do
    attributes do
      attribute :answer_id do |p|
        link_to(p.answer, simple_admin_answer_path(p.answer))
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
