class Api::WishlistItemsController < Api::BaseController
  def create
    @item = current_user.wishlist(params[:item])
    @status = @item.new_record?? 200 : 409
    @item.save!
    render :json => @item, :status => @status
  end
  
  def destroy
    @item = current_user.wishlist_items.find(params[:id])
    @item.destroy
    head :ok
  end
end