class ApplicationController < ActionController::Base
    before_action :login_required,:set_user_instance

    def login_required
        redirect_to controller: '/user' ,action: :index if session[:user].blank?
    end
    def set_user_instance
        @user = User.new(session[:user])
    end
end
