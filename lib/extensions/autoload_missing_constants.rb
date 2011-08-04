module AutoloadMissingConstants
  def self.protect
    begin
      yield
    rescue ArgumentError => e
      raise unless e.to_s =~ /undefined class/ # unexpected error message, re-raise
      e.to_s.split.last.constantize            # raises NameError if it can't find the constant
      retry
    end
  end
end