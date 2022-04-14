class UserController < ActionController::Base
    def index

    end
    def login
        if true #登入判斷式
            session[:user] = params[:login_user]
            PromotionCount::generate_person_txt(params[:login_user])
        end
        redirect_to controller: '/order', action: :index
    end

    def logout
        session[:user] = ''
        redirect_to controller: '/order', action: :index
    end
    
end
