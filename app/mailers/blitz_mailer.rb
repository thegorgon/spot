class BlitzMailer < ApplicationMailer
  layout 'blitz'
  
  def email(recipient, day)
    @email = recipient.email
    @title = "Jump the Velvet Rope for $5 a Month"
    if schedule[:quotes].include?(day)
      attachments.inline["header.png"] = File.read(Rails.root.join("public", "images", "email", "blitz", "quoteheader.png"))
      attachments.inline["quote.png"] = File.read(Rails.root.join("public", "images", "email", "blitz", "quote#{day}.png"))
    else
      attachments.inline["header.png"] = File.read(Rails.root.join("public", "images", "email", "blitz", "header#{day}.png"))      
    end
    mail(:template_name => "email#{day}")
  end
  
  private
  
  def set_inline_attachments
  end

  def schedule
    {
      :quotes => [1,2,3]
    }
  end
end