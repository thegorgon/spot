module SiteHelper
  def js_vars
    {
      :env => Rails.env
    }.to_json
  end
end