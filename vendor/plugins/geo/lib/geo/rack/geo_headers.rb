module Geo
  module Rack
    class GeoHeaders
      def initialize(app)
        @app = app
      end

      def call(env)
        request = ::Rack::Request.new(env)
        
        if position = ::Geo::Position.from_http_header(env['HTTP_GEO_POSITION'] || env['HTTP_X_GEO_POSITION'])
          Rails.logger.info("geo-headers : parsed position from http header to #{position.to_s}")
          request.params[:geo_position] = position
        end

        @app.call(env)
      end
    end
  end
end