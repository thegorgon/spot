class Api::WishlistsController < Api::BaseController  
  def show
    record_user_event("api wishlist load")
    render :json => current_user.wishlist
  end
end