module SiteHelper
  def js_vars
    {
      :env => Rails.env,
      :preload => [ ],
      :member => current_member?
    }.to_json
  end
  
  def current_member?
    if @current_member.nil?
      @current_member = !!current_user.try(:member?)
    end
    @current_member
  end
  
  def profile(name, email_or_url, title, options={})
    names = name.split(' ')
    content = image_tag("assets/drawings/#{names.first.downcase}.png", :height => "150", :class => "knmiv")
    content << content_tag(:div, name.html_safe, :class => "name tf")
    content << content_tag(:div, title.html_safe, :class => "title")
    ((options[:class] ||= "") << " profile preload ").strip!
    if email_or_url.index('@')
      options[:encode] = "hex"
      mail_to "#{name} <#{email_or_url}>".html_safe, content, options
    else
      link_to content, email_or_url, options
    end
  end
end