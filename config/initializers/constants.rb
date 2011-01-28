EMAIL_REGEX = /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i
REVISION = Rails.env.production?? `cat REVISION` : Time.now.to_i.to_s