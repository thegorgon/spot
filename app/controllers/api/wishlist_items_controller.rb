class Api::WishlistItemsController < Api::BaseController
  def create
    @item = current_user.wishlist_items.new(params[:item])
    @item.search_id = (request.headers["X-Search-ID"] || session[:last_search_id]).to_i
    status = 200
    begin
      @item.save!
    rescue ActiveRecord::RecordNotUnique => e
      @item = current_user.wishlist_items.where(params[:item].slice(:item_type, :item_id))
      status = 409
    end
    render :json => @item, :status => status
  end
  
  def destroy
    @item = current_user.wishlist_items.find(params[:id])
    @item.destroy
    @wishlist = current_user.wishlist_items.all(:include => :item)
    head :ok
  end
end