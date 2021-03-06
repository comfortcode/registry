class SessionsController < Devise::SessionsController

  def create
    self.resource = warden.authenticate!(auth_options)
    flash[:notice] = "Welcome back, #{current_user.couple_first_names}!" if is_flashing_format?
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_with resource, location: after_sign_in_path_for(resource)
  end
  
    # GET /resource/sign_in
  # def new
  #   # if params[:user]
  #   #   flash[:alert] = "Incorrect login or password"
  #   # end
  #   self.resource = resource_class.new(sign_in_params)
  #   clean_up_passwords(resource)
  #   yield resource if block_given?
  #   respond_with(resource, serialize_options(resource))
  # end
  
end