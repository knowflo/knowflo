module ApplicationHelper
  def auth_popup_link(provider=:facebook, &block)
    link_to(auth_path(provider), { :class => 'popup', :'data-width' => 600, :'data-height' => 400 }, &block)
  end

  def render_flash
    if message = flash[:error]
      div_class = 'error'
      div_title = 'Oh noes!'
    elsif message = flash[:success]
      div_class = 'success'
      div_title = 'Success!'
    elsif message = flash[:info]
      div_class = 'info'
      div_title = 'Heads up!'
    elsif message = flash[:notice]
      div_class = 'info'
    else
      return nil
    end

    <<-EOM
    <div class="alert alert-#{div_class}">
      <a class="close" data-dismiss="alert">x</a>
      <strong>#{div_title}</strong>
      <span>#{message}</span>
    </div>
    EOM
  end

  def nav_link(text, options={}, html_options={}, &block)
    link_class = current_page?(options) ? 'active navlink' : 'navlink'
    content_tag(:li, :class => link_class) do
      link_to(text, options, html_options, &block)
    end
  end

  def post_format(text)
    sanitize text.html_safe
    # sanitize Kramdown::Document.new(text.strip).to_html
  end

  def comment_format(comment)
    text = "#{comment.body} &mdash; #{raw link_to(comment.user.name, '#')}, #{time_ago_in_words(comment.created_at)} ago"
    text += " <em>(updated)</em>" if comment.updated_at > comment.created_at + 1.minute
    post_format(text)
  end

  def upvote_class(answer)
    answer_vote_class(answer, 1)
  end

  def downvote_class(answer)
    answer_vote_class(answer, -1)
  end

  def answer_vote_class(answer, direction)
    if logged_in?
      value = answer.vote_for(current_user)
      value == direction ? 'active' : ''
    else
      'disabled'
    end
  end

  def owner_logged_in?(obj)
    logged_in? && obj.try(:user) == current_user
  end

  def default_sidebar
    render('groups/sidebar', :base => logged_in? ? Question.visible(current_user) : Question.public_questions, :new_path => logged_in? ? new_question_path : nil)
  end

  def mine_or_yours(user, text)
    if logged_in? && user == current_user
      "My #{text}"
    else
      "#{user.first_name}'s #{text}"
    end
  end
end
