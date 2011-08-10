if Rails.env.production?
  Braintree::Configuration.environment = :production
  Braintree::Configuration.merchant_id = "5fmbtfddr3gnvn3m"
  Braintree::Configuration.public_key = "4snsbj93dcfpy42n"
  Braintree::Configuration.private_key = "zp93hkc322hxk8zy"
else
  Braintree::Configuration.environment = :sandbox
  Braintree::Configuration.merchant_id = "4jbkvg565mss3pmx"
  Braintree::Configuration.public_key = "t2nx68rgb72xtq5h"
  Braintree::Configuration.private_key = "mfsh9nz8qghrfv9z"
end