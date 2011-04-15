class Api::WishlistsController < Api::BaseController  
  def show
    record_user_event("api wishlist load")
    @wishlist = current_user.wishlist_items.active.all(:include => :item)
    render :json => @wishlist
  end
end