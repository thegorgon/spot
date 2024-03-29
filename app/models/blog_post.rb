class BlogPost < ActiveRecord::Base
  TOPICS = ["Events", "Guest Posts", "Hot on Spot", "News", "Press", "Spot Team", "Wishlist Wednesdays", "App", "Blogs We Love"]
  validates :slug, :presence => true
  validates :tumblr_id, :presence => true
  
  def self.filter(params={})
    search = { :page => params[:page], :per_page => params[:per_page], :tagged => params[:tag], :search => params[:q] }
    key = "blog/items?#{search.to_query}&v=#{AppSetting.get(:blog_revision)}"
    posts = nil
    AutoloadMissingConstants.protect do
      posts = Rails.cache.fetch(key, :expires_in => 1.week) do 
        Wrapr::Tumblr::Item.paginate(search)
      end
      if posts.error?
        Rails.cache.delete(key)
        posts = nil
      end
    end
    posts
  end
  
  def self.fetch(slug)
    post = nil
    record = BlogPost.find_by_slug(slug)
    if (record)
      AutoloadMissingConstants.protect do
        key = "blog/items/#{record.tumblr_id}?v=#{AppSetting.get(:blog_revision)}"
        post = Rails.cache.fetch(key, :expires_in => 1.week ) do
          Wrapr::Tumblr::Item.find(record.tumblr_id)
        end
        if post.nil?
          Rails.cache.delete(key)
          post = nil
        end
      end
    else
      raise ActiveRecord::RecordNotFound
    end
    post
  end
  
  def self.refresh(options={})
    page = 1
    per_page = 100
    max_page = options[:max_page]
    loop do
      items = Wrapr::Tumblr::Item.paginate(:page => page, :per_page => per_page)
      if items && items.success?
        page = items.next_page
        items.each do |item|
          record = BlogPost.find_or_initialize_by_slug(item.slug)
          record.tumblr_id = item.id
          record.save
        end
        break if page.nil? || (max_page && page > max_page)
      end
    end
  end
end