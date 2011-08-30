EMAIL_REGEX = /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i
REVISION = Rails.env.production?? `cat REVISION` : Time.now.to_i.to_s
HOSTNAME = `whoami`
S3_CONFIG = YAML.load_file(File.join(Rails.root, 'config', 'apis', 's3.yml'))
S3_HOST = S3_CONFIG[Rails.env]['host']
S3_BUCKET = S3_CONFIG[Rails.env]['bucket']
S3_BUCKET_URL = "http://#{S3_BUCKET}.s3.amazonaws.com/"
PHONE_NUMBER = "1-888-817-5410"
HOSTS = {
  "production" => "www.spotmembers.com",
  "staging" => "staging.spotmembers.com",
  "development" => "www.rails.local:3000"
}
API_HOSTS = {
  "production" => "api.spotmembers.com",
  "staging" => "api.staging.spotmembers.com",
  "development" => "api.rails.local:3000"
}
IMGHOST = "http://#{HOSTS[Rails.env]}/images/"
FBAPP = {
  :id => Rails.env.production?? 146911415372759 : 329653055238,
  :host => HOSTS[Rails.env]
}
MAILCHIMP = YAML.load_file(File.join(Rails.root, 'config', 'apis', 'mailchimp.yml'))