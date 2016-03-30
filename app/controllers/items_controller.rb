class ItemsController < ApplicationController

  def index
    @user = User.find_by(link_id: params[:link_id])
    unless @user
      flash[:notice] = 'No Registry Found'
      redirect_to root_path and return
    end
    @fulfillment = Fulfillment.new
    @item = Item.new        
    # Sort items registry based on params provided by sort dropdown 
    sort_by = params[:sort_by]
    if @user.items.any?
      if sort_by == "price_high"
        @items = @user.items.by_fulfilled.by_price_high
      elsif sort_by == "price_low"
        @items = @user.items.by_fulfilled.by_price_low
      elsif sort_by == "vendor"
        fulfilled_items=@user.items.fulfilled.sort { |a,b| a.store_name.downcase <=> b.store_name.downcase }
        unfulfilled_items=@user.items.unfulfilled.sort { |a,b| a.store_name.downcase <=> b.store_name.downcase }
        @items= unfulfilled_items+fulfilled_items
      else 
        @items = @user.items.by_fulfilled
      end 
     else
        @items = []
     end
      
end
#     authorize @items

  def new
    #     @item = Item.new - This is defined in the index method
    #     authorize @item
  end
  
  
  # Save a new item
  def create
    @item = Item.new(item_params)
#     authorize @item
    @item.user = current_user    
    if @item.save
      flash[:notice] = "\"#{@item.name}\" was added to your registry."
    else
      flash[:error] = "There was a problem adding the item to your registry. Please try again."
    end
    redirect_to user_registry_path(current_user.link_id)
  end
    
  def edit
    @item = Item.find(params[:id])
    # authorize @item
  end
  
  def update
    @item = Item.find(params[:id])
    # authorize @item
    @item.update_attributes(item_params)
    redirect_to user_registry_path(current_user.link_id)
  end 
  
  def destroy
    @item = Item.find(params[:id])
#     authorize @item
    if @item.destroy
      flash[:notice] = "\"#{@item.name}\" was deleted from your registry."
     else
      flash[:error] = "There was an error deleting the item from your registry."
     end
     redirect_to user_registry_path(current_user.link_id)
  end

  # Render data for a user to mark an item as fulfilled (create a new fulfillment) on their own registry
  def got_it
    @fulfillment = Fulfillment.new
    @item = Item.find(params[:id])
    # Select all unseen fulfillments for the item to display to the user 
    # (so the user doesn't create a duplicate fulfillment)
    @unseen_fulfillments = @item.fulfillments.where(status: 0)
  end
  
private 
  
  def item_params
    params.require(:item).permit(:name, :link, :price, :needed, :image_url, :notes, :color, :size)
   end

end