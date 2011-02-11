class Api::WishlistItemsController < Api::BaseController
  def create
    @item = current_user.wishlist_items.new(params[:item])
    @item.save!
    @wishlist = current_user.wishlist_items.all(:include => :item)
    render :json => {:wishlist => @wishlist}
  end
  
  def destroy
    @item = current_user.wishlist_items.find(params[:id])
    @item.destroy
    @wishlist = current_user.wishlist_items.all(:include => :item)
    render :json => {:wishlist => @wishlist}
  end
end