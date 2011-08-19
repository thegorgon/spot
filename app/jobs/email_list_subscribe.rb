module Jobs
  class EmailListSubscribe
    @queue = :processing
    
    def self.perform(id, oldemail=nil)
      client = Hominid::API.new(MAILCHIMP['api_key'])
      email = EmailSubscriptions.find(id)
      merge = {}
      { "FNAME" => email.first_name,
        "LNAME" => email.last_name, 
        "CITYSLUG" => email.city.try(:slug),
        "OTHERCITY" => email.other_city,
        "GROUPINGS" => [ {'name' => "Subscriptions", 'groups' => email.subscriptions.map { |sxn| sxn.humanize.titlecase }.join(',')},
                         {'name' => 'Cities', 'groups' => email.city.try(:name).to_s.titlecase }
                       ] 
      }.each do |key, value|
        merge[key] = value if value.present?
      end
  
    
      if oldemail.present?
        Rails.logger.debug("[spot] unsubscribing #{oldemail} from mailchimp")
        client.list_unsubscribe(MAILCHIMP["lists"]["subscriptions"]["id"], oldemail, true, false, false) rescue nil
      end
    
      Rails.logger.debug("[spot] subscribing #{email.email} to mailchimp with params #{merge.inspect}")
      client.list_subscribe(MAILCHIMP["lists"]["subscriptions"]["id"], email.email, merge, 'html', false, true, true, false)
    end    
  end
end