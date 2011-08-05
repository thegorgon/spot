class Site::BlogController < Site::BaseController   
  layout 'site/blog'
  
  def index
    @posts = BlogPost.filter(params)
    respond_to do |wants|
      wants.xml { render :layout => false }
      wants.html
    end
    @page_keywords = BlogPost::TOPICS
    @page_title = "The Spot Blog - Spot Membership Experiences"
  end
  
  def show
    @post = BlogPost.fetch(params[:id])
    @page_keywords = @post.tags
    @page_title = "#{@post.title} - The Spot Blog"
  end
  
  def refresh
    BlogPost.refresh(:max_page => params[:max_page])
    AppSetting.set!(:blog_revision, Time.now.to_i)
    redirect_to blog_index_path
  end
end