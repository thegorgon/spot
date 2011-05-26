class PlacepopEmail < ActiveRecord::Base
  validates :email, :presence => true, :uniqueness => true
  validates :first_name, :presence => true

  def self.import(file)
    require 'csv'
    csv = CSV.open(file, 'r')
    keys = csv.shift.compact.collect { |k| k.strip }
    records = csv.collect do |row|
      hash = {}
      row.each_with_index do |value, i|
        value = value.strip if value.respond_to?(:strip)
        value = nil if value == "NULL"
        hash[keys[i].downcase] = value if keys[i]
      end
      if hash["email"].present? && hash["first_name"].present?
        email = find_or_initialize_by_email(hash["email"])
        email.attributes = hash
        email.save! 
      end
    end    
  end
end