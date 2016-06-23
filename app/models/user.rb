class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
  has_many :items, dependent: :destroy
  
  before_create :generate_link
     
  def unseen_fulfillments
    items = self.items
    fulfillments = []
    items.each do |i|
      i.fulfillments.each do |f|    
        if f.status == 0
          fulfillments.push(f)
        end
      end 
    end 
  fulfillments
  end 

  def couple_first_names
    names = first_name
    unless other_first_name.empty?
      names += " & #{other_first_name}" 
    end
    names
  end

  def couple_full_names
    names = "#{first_name} #{last_name}"
    unless other_first_name.empty? && other_last_name.empty?
      names += " & #{other_first_name} #{other_last_name}"
    end
    names    
  end  

  protected

# Generates a unique 5 character id for the user's registry...
  def generate_link
        self.link_id = loop do
           random_id = SecureRandom.urlsafe_base64(5, false)
           break random_id unless self.class.exists?(link_id: random_id)
        end
  end
  
end