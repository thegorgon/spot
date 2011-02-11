class Api::WishlistsController < Api::BaseController
  def show
    @wishlist = current_user.wishlist_items.all(:include => :item)
    render :json => {:wishlist => @wishlist}
  end
end