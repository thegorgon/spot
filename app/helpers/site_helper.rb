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
                    '/images/assets/popover/lftpad40x1.png',
                    '/images/assets/popover/rtpad40x1.png',
                    '/images/assets/popover/ftpad1x40.png',
                    '/images/assets/popover/ftl40x40.png',
                    '/images/assets/popover/ftr40x40.png',
                    '/images/assets/popover/hdarr40x40.png',
                    '/images/assets/popover/hdl40x60.png',
                    '/images/assets/popover/hdpad1x40.png',
                    '/images/assets/popover/hdr40x60.png',
                    '/images/assets/popover/titled_hdarr40x75.png',
                    '/images/assets/popover/titled_hdl40x75.png',
                    '/images/assets/popover/titled_hdpad1x75.png',
                    '/images/assets/popover/titled_hdr40x75.png']
    }.to_json
  end
  
  def profile(name, email, title, nick)
    names = name.split(' ')
    content = image_tag("assets/drawings/#{names.first.downcase}.png", :height => "150", :class => "knmiv")
    name_with_nick = nick ? "#{names[0]} &ldquo;#{nick}&rdquo; #{names[1]}" : name
    content << content_tag(:div, name_with_nick.html_safe, :class => "name")
    content << content_tag(:div, title.html_safe, :class => "title")
    mail_to "#{name} <#{email}>".html_safe, content, :encode => "hex", :class => "shadowed profile hoverable preload dark"
  end
end