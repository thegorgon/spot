module Wrapr
  class Request
    module Cacheing
      def load_from_cache
        begin
          cache_value = Rails.cache.read(cache_string)
          @response = cache_value[:response] if cache_value && Time.now < cache_value[:expires]
        rescue ArgumentError => e
          raise unless e.to_s =~ /undefined class/ # unexpected error message, re-raise
          e.to_s.split.last.constantize            # raises NameError if it can't find the constant
          retry
        end
      end

      def cache_string
        string = "#{self.class.to_s.underscore}/v1#{request_path}"
        string << (string.index('?') ? "&#{@body}" : "?#{@body}") if @body.present?
        string
      end
    end
  end
end