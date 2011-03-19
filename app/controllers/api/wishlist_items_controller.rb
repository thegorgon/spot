class Api::WishlistItemsController < Api::BaseController
  def create
    @item = current_user.wishlist_items.new(params[:item])
    status = 200
    begin
      @item.save!
    rescue ActiveRecord::RecordNotUnique => e
      @item = current_user.wishlist_items.where(params[:item].slice(:item_type, :item_id)).first
      status = 409
    end
    render :json => @item, :status => status
  end
  
  def destroy
    @item = current_user.wishlist_items.find(params[:id])
    @item.destroy
    head :ok
  end
end