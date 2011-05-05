module ExternalPlace
  def self.included(base)
    base.send(:extend, Macros)
  end
  
  def self.sources
    [ExternalPlace::GooglePlace, ExternalPlace::YelpPlace, ExternalPlace::FoursquarePlace, ExternalPlace::GowallaPlace, ExternalPlace::FacebookPlace]
  end
  
  def self.lookup(symbol)
    if symbol.kind_of?(Class)
      symbol
    else
      "ExternalPlace::#{symbol.to_s.classify}Place".constantize
    end
  end
  
  def self.associated_with(place_ids)
    associated = {}
    sources.each do |source| 
      places = source.where(:place_id => place_ids).all.hash_by { |p| p.place_id }
      place_ids.each do |id|
        (associated[id] ||= {})[source.to_sym] = places[id]
      end
    end
    associated
  end
  
  module Macros
    def external_place(options)
      @_external_place_options = options
      send(:acts_as_mappable)
      belongs_to :place
      validates :lat, :numericality => {:greater_than => -90, :less_than => 90}, :presence => true
      validates :lng, :numericality => {:greater_than => -180, :less_than => 180}, :presence => true
      validates options[:id].to_sym, :presence => true
      include InstanceMethods
      extend ClassMethods      
      @_external_place_options[:alias] ||= {}
      @_external_place_options[:alias].each do |newname, oldname|
        define_method("#{newname}") do
          send(oldname)
        end
      
        define_method("#{newname}=") do |value|
          send("#{oldname}=", value)
        end
      end
    end
  end
  
  module ClassMethods
    def search(params={})
      results = @_external_place_options[:wrapr].search(params, :cache => true, :cache_expiry => 1.day)
      if results.present?
        results.map! { |wrapr| from_wrapr(wrapr) }
        results = results.hash_by { |p| p.send(@_external_place_options[:id]) }
        saved = where(@_external_place_options[:id] => results.keys).includes(:place).all
        saved = saved.hash_by { |p| p.send(@_external_place_options[:id]) }
        results.keys.each do |id|
          results[id] = saved[id] if saved[id]
        end
        results.values
      else
        []
      end
    end
    
    def fetch(id)
      wrapr = @_external_place_options[:wrapr].find(id)
      result = from_wrapr(wrapr)
      id_method = @_external_place_options[:id]
      saved = where(id_method => result.send(id_method)).includes(:place).first
      saved || result
    end
    
    def to_sym
      to_s.gsub("ExternalPlace::", '').gsub("Place", "").downcase.to_sym
    end
  end
  
  module InstanceMethods
    def source_id
      id_method = self.class.instance_variable_get("@_external_place_options")[:id]
      send(id_method)
    end
    
    def name_with_city
      string = name.clone
      string << " in #{city.titlecase}" if city.present?
      string
    end
    
    def bind_to!(place)
      place.save if place.changed?
      self.place = place
      begin
        save! if place_id && changed?
      rescue ActiveRecord::StatementInvalid => error
        raise error unless error.to_s =~ /Mysql2::Error: Duplicate/
        existing = self.class.where(@_external_place_options[:id] => source_id)
        self.id = existing.id
        reload
      end
    end

    def bind_to_place!
      binding = place ? place.canonical : to_place
      bind_to! binding
      place
    end
    
    def to_place
      p = ::Place.new
      [:name, :address_lines, :lat, :lng, :city, :region, :country, :phone_number].each do |key|
        p.send("#{key}=", send(key)) if respond_to?(key)
      end
      p.source = self.class.to_s
      p      
    end
    
    def full_address
      address_lines.join("\n")
    end
  end
end

ActiveRecord::Base.send(:include, ExternalPlace)