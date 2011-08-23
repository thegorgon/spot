class AcquisitionCohort < ActiveRecord::Base
  belongs_to :acquisition_source
  belongs_to :acquisition_campaign
    
  def self.clicked!(campaign, source, user)
    campaign_cohort(campaign).clicked!(user)
    source_cohort(source).clicked!(user)
  end

  def self.email_acquired!(campaign, source)
    campaign_cohort(campaign).email_acquired!
    source_cohort(source).email_acquired!
  end

  def self.applied!(campaign, source)
    campaign_cohort(campaign).applied!
    source_cohort(source).applied!
  end

  def self.signup!(campaign, source)
    campaign_cohort(campaign).signup!
    source_cohort(source).signup!
  end

  def self.member!(campaign, source, membership)
    campaign_cohort(campaign).member!(membership)
    source_cohort(source).member!(membership)
  end

  def self.registration!(campaign, source)
    campaign_cohort(campaign).registration!
    source_cohort(source).registration!
  end

  def self.unsubscribed!(campaign, source)
    campaign_cohort(campaign).registration!
    source_cohort(source).registration!
  end
  
  def self.campaign_cohort(campaign)
    date ||= Time.now.utc.to_date
    find_or_create_by_date_and_acquisition_campaign_id_and_acquisition_source_id(
      date,
      campaign.id,
      nil
    )
  end

  def self.source_cohort(source)
    date ||= Time.now.utc.to_date
    find_or_create_by_date_and_acquisition_campaign_id_and_acquisition_source_id(
      date,
      source.acquisition_campaign_id,
      source.id
    )
  end
  
  def clicked!(user)
    count!(user.try(:member?) ? :member_clicks : :nonmember_clicks)
  end
  
  def email_acquired!
    count!(:emails)
  end

  def signup!
    count!(:signups)
  end
  
  def applied!
    count!(:signups)
  end
  
  def member!(membership)
    count!(:memberships)
    count!( membership.payment_method.billing_period == 1 ? 
              :monthly_subscribers : 
              :annual_subscribers) if membership.payment_method.respond_to?(:billing_period)
              
  end

  def registration!
    count!(:registrations)
  end
  
  def unsubscribed!
    count!(:unsubscriptions)
  end

  private
  
  def count!(field, amount=1)
    self.class.update_counters(id, field => amount)
  end
end