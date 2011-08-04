xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "The Spot Blog"
    xml.description "Blog for http://#{HOSTS['production']}"
    xml.link blog_index_url

     @posts.each do |post|
      xml.item do
        if post.kind_of?(Wrapr::Tumblr::Regular)
          xml.title post.title.html_safe
          xml.description post.body.html_safe
        elsif post.kind_of?(Wrapr::Tumblr::Photo)
          xml.title "A Photo"
          xml.description post.caption.html_safe
        end
        xml.pubDate post.date.to_s(:rfc822)
        xml.link blog_url(post)
      end
    end
  end
end