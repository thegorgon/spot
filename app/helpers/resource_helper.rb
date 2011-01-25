module ResourceHelper

  # Embed stylesheet assets into the page header. In production mode, uses CDN and/or optimized resources.
  #
  # ==== Returns
  #
  # String:: HTML stylesheet references.
  #
  def embed_stylesheets
    stylesheet_link_chomped(:placepop, :media => :all)
  end

  # Embed javascript assets into the page header. In production mode, uses CDN and/or optimized resources.
  #
  # ==== Returns
  #
  # String:: HTML javascript references.
  #
  def embed_javascripts
    javascript_include_chomped(:vendor, :placepop)
  end
  
  # Embed an external javascript file
  #
  # ==== Returns
  #
  # String:: HTML javascript references.
  #
  def external_js_include_tag(source, options={})
    content_tag("script", "", { "type" => Mime::JS, "src" => source }.merge(options))
  end

end