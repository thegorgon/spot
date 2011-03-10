module Wrapr
  class Request
    module Cacheing
      def load_from_cache
        begin
          @response = Rails.cache.read(cache_string)
        rescue ArgumentError => e
          raise unless e.to_s =~ /undefined class/ # unexpected error message, re-raise
          e.to_s.split.last.constantize            # raises NameError if it can't find the constant
          retry
        end
      end

      def cache_string
        string = "#{self.class.to_s.underscore}#{request_path}"
        string << (string.index('?') ? "&#{@body}" : "?#{@body}") if @body.present?
        string
      end
    end
  end
end