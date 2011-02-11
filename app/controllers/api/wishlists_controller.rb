class Api::WishlistsController < Api::BaseController
  def show
    render :json => {:wishlist => current_user.wishlist_items}
  end
end