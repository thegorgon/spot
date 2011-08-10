module BlogHelper
  def byline(post)
    if post.author
      "by #{post.author} on #{post.date_string}"
    else
      post.date_string
    end
  end
  
  def truncate_string(string, length)
    words = string.split(' ')
    result = ""
    words.each do |word|
      result << " #{word}"
      break if result.length >= length
    end
    result.gsub!(/[^a-zA-Z0-9]$/, '')
    result
  end

  def preview(post)
    body = post.body.to_s
    preview = ""
    tagstack = []
    body.scan(/\<p\>(.+?)<\/p\>/) do |m|
      if preview.length + m[0].to_s.length > 500
        break
      else
        preview << "<p>#{m[0]}</p>"
      end
    end
    preview.html_safe
  end  

  def post_tweet(post)
    post.respond_to?(:title) ? post.title : "From The Spot Blog"
  end
  
  def post_url(post)
    blog_url(post, :host => HOSTS['production'])
  end
end