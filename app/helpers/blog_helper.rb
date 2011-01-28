module BlogHelper
  def byline(post)
    if post.author
      "by #{post.author} on #{post.date_string}"
    else
      post.date_string
    end
  end
end