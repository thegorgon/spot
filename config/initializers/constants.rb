EMAIL_REGEX = /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i
REVISION = Rails.env.production?? `cat REVISION` : Time.now.to_i.to_s
HOSTNAME = `whoami`
S3_CONFIG = YAML.load_file(File.join(Rails.root, 'config', 'apis', 's3.yml'))
S3_HOST = S3_CONFIG[Rails.env]['host']
S3_BUCKET = S3_CONFIG[Rails.env]['bucket']
S3_BUCKET_URL = "http://#{S3_BUCKET}.s3.amazonaws.com/"
REQUIRE_SSL = false