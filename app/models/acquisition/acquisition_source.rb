class AcquisitionSource < ActiveRecord::Base
  belongs_to :acquisition_campaign
  
  def self.filter(params)
    finder = self
    finder = finder.where(:acquisition_campaign_id => params[:cmp]) if params[:cmp]
    finder.page(params[:page]).per(params[:per_page])
  end
  
  def clicked!(user)
    count!(user.try(:member?) ? :member_clicks : :nonmember_clicks)
    AcquisitionCohort.clicked!(acquisition_campaign, self, user)
  end
  
  def email_acquired!
    count!(:emails)
    AcquisitionCohort.email_acquired!(acquisition_campaign, self)
  end

  def applied!
    count!(:applications)
    AcquisitionCohort.applied!(acquisition_campaign, self)    
  end
  
  def signup!
    count!(:signups)
    AcquisitionCohort.signup!(acquisition_campaign, self)
  end
  
  def member!(membership)
    count!(:memberships)
    count!( membership.payment_method.billing_period == 1 ? 
              :monthly_subscribers : 
              :annual_subscribers) if membership.payment_method.respond_to?(:billing_period)
              
    AcquisitionCohort.member!(acquisition_campaign, self, membership)
  end

  def registration!
    count!(:registrations)
    AcquisitionCohort.registration!(acquisition_campaign, self)
  end

  def unsubscribed!
    count!(:unsubscriptions)
    AcquisitionCohort.unsubscribed!(acquisition_campaign, self)
  end

  def total_clicks
    member_clicks + nonmember_clicks
  end

  private
  
  def count!(field, amount=1)
    self.class.update_counters(id, field => amount)
  end
end