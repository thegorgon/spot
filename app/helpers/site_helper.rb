module SiteHelper
  def js_vars
    {
      :env => Rails.env,
      :max_joke_id => PreviewSignup::CURRENT_TESTS.max,
      :preload => [ '/images/buttons/black_button_77x32_active.png', 
                    '/images/buttons/black_button_77x32_hover.png',
                    '/images/buttons/orange_button156x31_hover.png', 
                    '/images/buttons/orange_button156x31_active.png',
                    '/images/assets/general/search_dark13x14.png' ]
    }.to_json
  end
end