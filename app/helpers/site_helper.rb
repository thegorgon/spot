module SiteHelper
  def js_vars
    {
      :env => Rails.env,
      :max_joke_id => PreviewSignup::CURRENT_TESTS.max
    }.to_json
  end
end