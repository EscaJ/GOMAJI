class PromotionController < ApplicationController
    def check_promotion
        resp = {resp: 'success'}
        begin
            cart_params = params[:cart].permit(:products,:sum)
            product_arr = params[:cart][:products].map{|x| {name: x[:name],nums: x[:nums]}}
            promotion = Promotion.new(product_arr,params[:cart][:sum].to_i)
            promotion.range_discount(true)
            promotion.product_discount(true)
            promotion.range_free_gift(true)
            promotion.range_discount_by_site(true)
            promotion.range_discount_by_user(@user.user_id,true)
            promotion.monthly_range_discount_by_site(true)
            resp[:msg] = promotion.msg.join('</br>')
            resp[:new_sum] = promotion.sum - promotion.discount
        rescue => exception
            logger.info 'qwert '+exception.message
            resp = {resp: 'fail',msg: '系統執行發生錯誤，請聯絡系統管理員'}
        end
       
        render json: resp.to_json
    end
end
