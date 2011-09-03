module Jobs
  class EmailListUnsubscribe
    @queue = :processing

    def self.perform(email)
      client = Hominid::API.new(MAILCHIMP['api_key'])
      if email.present?
        Rails.logger.debug("[spot] unsubscribing #{email} from mailchimp")
        client.list_unsubscribe(MAILCHIMP["lists"]["subscriptions"]["id"], email, true, false, false) rescue nil
      end
    end    
  end
end