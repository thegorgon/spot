class Api::WishlistItemsController < Api::BaseController
  def create
    @item = current_user.wishlist_items.new(params[:item])
    @item.save!
    render :json => {:wishlist => current_user.wishlist_items}
  end
  
  def destroy
    @item = current_user.wishlist_items.find(params[:id])
    @item.destroy
    render :json => {:wishlist => current_user.wishlist_items.reload}
  end
end