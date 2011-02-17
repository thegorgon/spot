module Geo
  class Position < Geo::LatLng
    attr_accessor :altitude, :uncertainty, :heading, :speed

    MATCH_LLA = /\A([+-]?[0-9\.]+);([+-]?[0-9\.]+)(?:;([+-]?[0-9\.]+))?/.freeze
    MATCH_EPU = /\sepu=([0-9\.]+)(?:\s|\z)/i.freeze
    MATCH_HDN = /\shdn=([0-9\.]+)(?:\s|\z)/i.freeze
    MATCH_SPD = /\sspd=([0-9\.]+)(?:\s|\z)/i.freeze

    def initialize(params={})
      super(params)
      self.altitude    = params[:altitude]
      self.uncertainty = params[:uncertainty]
      self.heading     = params[:heading]
      self.speed       = params[:speed]
    end
    
    # Parse Geo-Position header:
    # http://tools.ietf.org/html/draft-daviel-http-geo-header-05
    def self.from_http_header(value)
      value = value.to_s.strip
      position = new

      if lla = MATCH_LLA.match(value)
        position.lat = lla[1].to_f
        position.lng = lla[2].to_f
        position.altitude = lla[3].to_f if lla[3]
      end

      if epu = MATCH_EPU.match(value)
        position.uncertainty = epu[1].to_f
      end

      if hdn = MATCH_HDN.match(value)
        position.heading = hdn[1].to_f
      end

      if spd = MATCH_SPD.match(value)
        position.speed = spd[1].to_f
      end

      position.valid?? position : nil
    end
    
    def ==(other)
      # Same lat, lng, altitude, heading and speed. Ignore uncertainty
      super(other) && other.altitude == altitude && other.heading == heading && other.speed == speed
    end

    def valid?
      (!lat.nil? && lat.respond_to?(:to_f) && (-90..90).include?(lat.to_f)) &&
      (!lng.nil? && lng.respond_to?(:to_f) && (-180..180).include?(lng.to_f)) &&
      (altitude.nil? || altitude.respond_to?(:to_f)) &&
      (uncertainty.nil? || uncertainty.respond_to?(:to_f) && uncertainty.to_f >= 0) &&
      (heading.nil? || heading.respond_to?(:to_f) && (0..360).include?(heading.to_f)) &&
      (speed.nil? || speed.respond_to?(:to_f) && speed.to_f >= 0)
    end

    def attributes
      {
        :lat => lat,
        :lng => lng,
        :altitude => altitude,
        :uncertainty => uncertainty,
        :heading => heading,
        :speed => speed,
      }
    end

    def to_http_header
      value = "%f;%f" % [lat.to_f, lng.to_f]
      value += ";%f" % altitude.to_f if altitude
      value += " epu=%f" % uncertainty.to_f if uncertainty
      value += " hdn=%f" % heading.to_f if heading
      value += " spd=%f" % speed.to_f if speed
      value
    end

    private

    def reset!
      @lat = @lng = @altitude = @uncertainty = @heading = @speed = nil
    end
  end
end