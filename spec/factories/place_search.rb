Factory.define :place_search do |ps|
  ps.query        "Taqueria Altena"
  ps.position     Geo::Position.new(:lat => 33, :lng => -120, :uncertainty => 0, :timestamp => Time.now).to_http_header
  ps.lat          33
  ps.lng          -120
  ps.result_id    nil
end