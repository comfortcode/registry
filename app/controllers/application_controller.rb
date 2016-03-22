class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  include Pundit
  protect_from_forgery with: :exception
  
  before_filter :configure_permitted_parameters, if: :devise_controller?
  after_filter :store_location
  # after_action :verify_authorized, except: :index

  rescue_from Pundit::NotAuthorizedError do |exception|
     redirect_to root_url, alert: exception.message
  end  

    def store_location
      session[:previous_url] = request.fullpath unless request.fullpath =~ /\/users/
    end
  
    def after_sign_in_path_for(resource)
      user_registry_path(current_user.link_id)
    end

    def after_sign_out_path_for(resource_or_scope)
      begin
        controller_name = Rails.application.routes.recognize_path(request.referer)[:controller]
        controller_class = "#{controller_name}_controller".camelize.constantize
        authentication_callbacks = controller_class._process_action_callbacks.select { |callback| callback.filter.match /authenticate_\w+!/ }
        action_name = Rails.application.routes.recognize_path(request.referer)[:action]

        restricting_callbacks = []

        authentication_callbacks.each do |callback|
          callback_scope = callback.instance_variable_get(:@if)
          if callback_scope.empty? || callback_scope.first.match(/action_name\s==\s(\'|\")#{Regexp.quote(action_name)}(\'|\")/)
            restricting_callbacks << callback
          end
        end

        restricting_callbacks.empty? ? request.referer : root_path
      rescue Exception => e
        request.referer
      end
    end
  
  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:email, :first_name, :last_name, :wedding_date, :other_first_name, :other_last_name, :street, :city, :state, :zip, :password, :password_confirmation)
    end

    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit(:email, :first_name, :last_name, :wedding_date, :other_first_name, :other_last_name, :street, :city, :state, :zip, :password, :password_confirmation, :current_password)
    end
  end  
  
end
