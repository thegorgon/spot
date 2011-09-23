class BlitzMailer < ApplicationMailer
  layout 'blitz'
  
  def email(request, options={})
    @day = options[:day] || request.blitz_count + 1
    options[:invite] = "INVITE3FREE" if @day == 10
    @portal_url = portal_url(:mc => options[:invite] || InviteRequest.random_code, :cid => request.city.id, :ir => request.id)
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
    
    # add_attachment "topleft.png", ["email", "shadows", "topleft15x14.png"]
    # add_attachment "top.png", ["email", "shadows", "top100x14.png"]
    # add_attachment "topright.png", ["email", "shadows", "topright15x14.png"]
    # add_attachment "right.png", ["email", "shadows", "right15x100.png"]
    # add_attachment "bottomright.png", ["email", "shadows", "bottomright15x16.png"]
    # add_attachment "bottom.png", ["email", "shadows", "bottom100x16.png"]
    # add_attachment "bottomleft.png", ["email", "shadows", "bottomleft15x16.png"]
    # add_attachment "left.png", ["email", "shadows", "left15x100.png"]    
  end

  def schedule
    {
      :quotes => [2,5,7,10],
      :subject => [
        "Experiences You Can't Find Anywhere Else.",
        "One Membership, Unlimited Access.",
        "Spot Works Great On Your iPhone",
        "Benefit From Our Relationships",
        "Places You Love Will Love You Back",
        "Fall In Love With Local Hidden Gems",
        "Spot Supports Local Businesses",
        "We Keep It Fresh",
        "Bigger Isn't Always Better",
        "Membership Pays For Itself"
      ]
    }
  end
end