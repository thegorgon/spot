class Api::WishlistItemsController < Api::BaseController
  def create
    @item = current_user.wishlist(params[:item])
    @status = @item.new_record?? 200 : 409
    @item.save!
    record_user_event("api wishlist create", "#{@item.item_type} #{@item.item_id}")
    render :json => @item, :status => @status
  end
  
  def destroy
    @item = current_user.wishlist_items.find(params[:id])
    @item.destroy
    record_user_event("api wishlist destroy", "#{@item.item_type} #{@item.item_id}")
    head :ok
  end
end