class Admin::MembershipCodesController < Admin::BaseController
  def index
    @codes = MembershipCode.by_code
    @new_code = MembershipCode.new_code
  end
  
  def create
    @code = MembershipCode.new(params[:membership_code])
    if @code.save
      flash[:notice] = "Created code #{@code.code}"
    else
      @new_code = @code
      flash[:notice] = "Couldn't create code, Try again."
    end
    redirect_to admin_membership_codes_path
  end
  
  def destroy
    @code = MembershipCode.find_by_code(params[:id])
    @code.destroy
    redirect_to admin_membership_codes_path
  end  
end