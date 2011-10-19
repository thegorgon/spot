class BlitzMailer < ApplicationMailer
  ASRCID = 53
  layout 'blitz'
  
  def email(request, options={})
    @day = options[:day] || request.blitz_count + 1
    options[:invite] = "INVITE3FREE" if @day == 10
    @request = request
    @code = options[:invite] || InviteRequest.random_code.code
    @tracking = {:mc => @code, :asrc => ASRCID, :ir => request.id}
    @portal_url = new_application_url(@tracking)
    @city = request.city
    @email = request.email
    @reason = "#{schedule[:subject][@day - 1]}"
    
    if schedule[:quotes].include?(@day)
      add_attachment "header.png", ["email", "blitz", "quoteheader.png"]
      add_attachment "quote.png", ["email", "blitz", "day#{@day}quote.png"]
    else
      add_attachment "header.png", ["email", "blitz", "day#{@day}header.png"]
    end
    add_attachment "daynumber.png", ["email", "blitz", "day#{@day}.png"]

    @experiences = options[:experiences] || InviteRequest.blitz_experiences(@city)

    mail(:template_name => "email#{@day}", :subject => "Spot : #{@reason}")
  end
    
  private
  
  def set_inline_attachments
    add_attachment "footer.png", ["email", "blitz", "footer.png"]
  end

  def schedule
    {
      :quotes => [2,5,7,10],
      :subject => [
        "Perks You Can't Find Anywhere Else.",
        "One Membership, Unlimited Perks.",
        "Spot Works Great On Your iPhone.",
        "Know People. Get Perks.",
        "Places You Love Will Love You Back.",
        "Fall In Love With #{@city.name.titlecase} Hidden Gems.",
        "Spot Supports Local Businesses.",
        "Local Perks - Served Fresh.",
        "Bigger Isn't Always Better.",
        "Membership Pays For Itself."
      ]
    }
  end
end