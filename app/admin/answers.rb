SimpleAdmin.register :answer do
  index do
    attributes do
      clear
      attribute :question_id do |p|
        link_to(p.question, simple_admin_question_path(p.question))
      end
      attribute :body do |p|
        p.short_text
      end
      attribute :points_cache
      attribute :solution
      attribute :user_id do |p|
        link_to(p.user, simple_admin_user_path(p.user))
      end
      attribute :created_at
      attribute :updated_at
    end

    filters :only => [:solution, :points_cache, :body, :created_at, :updated_at]
  end

  show do
    attributes do
      attribute :question_id do |p|
        link_to(p.question, simple_admin_question_path(p.question))
      end
      attribute :user_id do |p|
        link_to(p.user, simple_admin_user_path(p.user))
      end
      attribute :body do |p|
        simple_format(p.body)
      end
    end
  end
end
