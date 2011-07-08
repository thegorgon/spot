module SiteHelper
  def js_vars
    {
      :env => Rails.env,
      :preload => [ ],
      :member => current_member?
    }.to_json
  end
  
  def current_member?
    !!current_user.try(:member?)
  end
  
  def profile(name, email_or_url, title, nick)
    names = name.split(' ')
    content = image_tag("assets/drawings/#{names.first.downcase}.png", :height => "150", :class => "knmiv")
    name_with_nick = nick ? "#{names[0]} &ldquo;#{nick}&rdquo; #{names[1]}" : name
    content << content_tag(:div, name_with_nick.html_safe, :class => "name")
    content << content_tag(:div, title.html_safe, :class => "title")
    if email_or_url.index('@')
      mail_to "#{name} <#{email_or_url}>".html_safe, content, :encode => "hex", :class => "shadowed profile hoverable preload dark"
    else
      link_to content, email_or_url, :class => "shadowed profile hoverable preload dark"
    end
  end
end