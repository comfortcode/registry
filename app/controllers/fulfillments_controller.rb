class FulfillmentsController < ApplicationController
  
  def index
    if current_user.unseen_fulfillments.empty?
      redirect_to user_registry_path(current_user.link_id)
    else
      @fulfillments = current_user.unseen_fulfillments
    end 
  end
  
  # Fulfillment Status: 0="Unseen", 1="Seen", 2="Spam"
  def mark_seen
    fulfillment = Fulfillment.find(params[:id])
    if fulfillment.status == 0 
      fulfillment.status = 1
      fulfillment.save
    else
      flash[:error] = "There was an error processing your request."
    end 
    redirect_to :back
  end 

 def mark_spam
   fulfillment = Fulfillment.find(params[:id])
   if fulfillment.status != 2 
    fulfillment.status = 2
    item = fulfillment.item
    item.fulfilled -= fulfillment.quantity
    if item.save && fulfillment.save
      flash[:notice] = "The fulfillment by #{fulfillment.buyer_name} was marked as spam."
    else
      flash[:error] = "There was an error processing your request."
    end
  else
    flash[:error] = "There was an error processing your request."
  end
  redirect_to :back
end 

 def user_create
   @fulfillment = Fulfillment.new(params.require(:fulfillment).permit(:buyer_name, :quantity, :item_id))
   @fulfillment.status = 1
   item = Item.find(@fulfillment.item_id)
   item.fulfilled += @fulfillment.quantity
   item.save
   gift = pluralize_gift(@fulfillment, item)
   gift = item.name   
  if @fulfillment.save
    flash[:notice] = "#{@fulfillment.quantity} #{gift} #{gift_verb(@fulfillment)} removed from your registry."
   else
    flash[:error] = "There was an error. #{@fulfillment.quantity} #{gift} #{gift_verb} not removed from your registry. Please try again later."
   end
  redirect_to user_registry_path(current_user.link_id)
end  
  
# Returns the verb to preceed: "removed from your registry"
def gift_verb(fulfillment)
      if fulfillment.quantity > 1
        "were"
      else
        "was"
      end
end 

def pluralize_gift(fulfillment, item)
      if fulfillment.quantity > 1
        item.name.pluralize
      else
        item.name
      end
  end 

  # Allows any visitor to create a fulfillment on a user's registry
  def create
    @fulfillment = Fulfillment.new(params.require(:fulfillment).permit(:buyer_name, :buyer_email, :quantity, :message, :item_id))
    item = Item.find(@fulfillment.item_id)
    item.fulfilled += @fulfillment.quantity
    item.save
    couple_names = "#{item.user.first_name} & #{item.user.other_first_name}"
#     gift = pluralize_gift(@fulfillment, item)
    gift = item.name
    if @fulfillment.save
      flash[:notice] = "Thank you! #{couple_names} were informed that you will be buying them #{@fulfillment.quantity} #{gift}"
    else
      flash[:error] = "There was an error processing your request. Please try again."
    end
  redirect_to :back
  end 

end