module SiteHelper
  def js_vars
    {
      :env => Rails.env,
      :max_joke_id => PreviewSignup::CURRENT_TESTS.max,
      :preload => [ '/images/buttons/black_button_77x32_active.png', 
                    '/images/buttons/black_button_77x32_hover.png',
                    '/images/buttons/orange_button156x31_hover.png', 
                    '/images/buttons/orange_button156x31_active.png',
                    '/images/assets/general/search13x14.png',
                    '/images/assets/popover/bottom220x25.png',
                    '/images/assets/popover/hood220x15.png',
                    '/images/assets/popover/middle220x1.png',
                    '/images/assets/popover/middle_left25x1.png',
                    '/images/assets/popover/middle_right25x1.png',
                    '/images/assets/popover/top_center220x60.png',
                    '/images/assets/popover/top_right220x60.png' ]
    }.to_json
  end
  
  def profile(name, email, title, nick)
    names = name.split(' ')
    content = image_tag("assets/drawings/#{names.first.downcase}.png", :height => "150")
    name_with_nick = "#{names[0]} &ldquo;#{nick}&rdquo; #{names[1]}"
    content << content_tag(:div, name_with_nick.html_safe, :class => "name")
    content << content_tag(:div, title.html_safe, :class => "title")
    mail_to "#{name} <#{email}>".html_safe, content, :encode => "hex", :class => "shadowed profile hoverable dark"
  end
end