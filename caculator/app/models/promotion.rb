class Promotion
    attr_accessor :products,:sum,:discount,:free_gifts,:msg
    #滿額折扣RANGE
    DISCOUNT = [{range_start: 10000,range_end: 20000,discount: 89},{range_start: 20000,range_end: Float::INFINITY,discount: 7}]
    #特定商品折扣
    REBATE_PRODUCT = [
        {name: '電腦螢幕',nums: 2,rebate: 500},
        {name: '音響',nums: 1,rebate: 300}
    ]
    #滿額送贈品
    FREE_GIFT = [{range_start: 5000 ,free_gifts: [{name: '滑鼠墊'}]},{range_start: 10000 ,free_gifts: [{name: '鍵盤滑鼠'}]}]

    #滿額折X元，限定次數
    RANGE_DISCOUNT_BY_SITE = [{range_start: 10000,range_end: '',rebate: 400}]
    #滿額折扣，限定單人特定額度
    RANGE_DISCOUNT_BY_USER = [{range_start: 20000,range_end: '',discount: 8}]
    #滿額折X元，限定每月全站限定額度
    MONTHLY_RANGE_DISCOUNT_BY_SITE = {M202204: [{range_start: 10000,range_end: '',rebate: 400}]}

    def initialize(products,sum)
        @products = products
        @sum = sum
        @discount = 0
        @free_gifts = []
        @msg = []
    end

    def cur_sum
        return self.sum - self.discount
    end

    #滿額%數折扣
    def range_discount(test_flag = false)
        discount_percent = 1
        #discount_obj = PromotionTable.where("type = '滿額折扣' and sum >= range_start and sum < range_end").first #目前無DB環境
        if test_flag #測試使用的資料
            #self.discount = PromotionTestTable.where("type = '滿額折扣' and sum >= range_start and sum < range_end").first #目前無DB環境
            discount_obj = Promotion::DISCOUNT.select{|h| sum >= h.range_start and sum < h.range_end}.first
        end
        
        discount_percent = "0.#{discount_obj.discount}".to_f if discount_obj.present?
        cur_discount = cur_sum - (cur_sum * discount_percent).ceil
        self.discount += cur_discount
        self.msg << "滿額#{discount_obj.range_start}打#{discount_obj.discount}折，共省下#{cur_discount}元"
    end
    #特定商品折扣
    def product_discount(test_flag = false)
        #rebate_group = PromotionTable.where("type='特定商品折扣'").group_by(&:name) #目前無DB環境
        if test_flag #測試使用的資料
            #rebate_group = PromotionTestTable.where("type='特定商品折扣'").group_by(&:name) #目前無DB環境
            rebate_group = Promotion::REBATE_PRODUCT.group_by{|r| r.name }
        end
        rebate = 0
        self.products.each do |h|
            cur_group = rebate_group[h.name].first rescue nil
            if cur_group.present? and h.nums.to_i >= cur_group.nums
                self.msg << "購買指定商品#{h.name}#{cur_group.nums}件折#{cur_group.rebate.to_i}元"
                rebate += cur_group.rebate.to_i
            end
        end
        self.discount += rebate
    end

    #滿額贈品
    def range_free_gift(test_flag = false)
        #free_gifts = PromotionTable.where("type='滿額贈品'").joins(:free_gifts) #目前無DB環境
        if test_flag #測試使用的資料
            #free_gifts = PromotionTestTable.where("type='滿額贈品'").joins(:free_gifts) #目前無DB環境
            free_gifts = Promotion::FREE_GIFT
        end
        free_gifts.each do |h|
            if self.sum >= h.range_start
                h.free_gifts.each do |free_gift|
                    self.msg << "滿額#{h.range_start}送贈品#{free_gift.name}1件"
                    self.free_gifts << {name: free_gift.name,nums: 1}
                end
            end
        end
    end

    #滿額折X元，限制X次
    def range_discount_by_site(test_flag=false)
        if test_flag
            #range_rebate = PromotionTestTable.where("type='次數限制滿額折價'") #目前無DB環境
            discount_obj = Promotion::RANGE_DISCOUNT_BY_SITE.
            select{|x| 
                cur_sum >= x.range_start and (x.range_end.blank? or cur_sum < x.range_end)
            }.first 
        end
        cur_cnt = PromotionCount.check_range_discount_by_site
        if cur_cnt > 0
            self.msg << "滿額#{discount_obj.range_start}折#{discount_obj.rebate}元，剩餘#{cur_cnt-1}人次可享有此優惠"
            self.discount += discount_obj.rebate
            PromotionCount.range_discount_by_site_reduce
        end
    end

    #滿額折扣，限定單人特定額度
    def range_discount_by_user(user_id,test_flag=false)
        discount_percent = 1
        if test_flag
            #range_discount = PromotionTestTable.where("type='個人限制滿額折扣'") #目前無DB環境
            discount_obj = Promotion::RANGE_DISCOUNT_BY_USER.
            select{|x| 
                cur_sum >= x.range_start and (x.range_end.blank? or cur_sum < x.range_end)
            }.first 
        end
        discount_percent = "0.#{discount_obj.discount}".to_f if discount_obj.present?
        cur_cnt = PromotionCount.check_range_discount_by_user(user_id)
        if cur_cnt > 0 and discount_obj.present? 
            cur_discount = cur_sum - (cur_sum * discount_percent)
            cur_discount = cur_cnt if cur_discount > cur_cnt 
            self.discount += cur_discount
            self.msg << cur_msg = "滿額#{discount_obj.range_start}打#{discount_obj.discount}折共折#{cur_discount}#{'已達上限'if cur_discount == cur_cnt}，個人優惠剩餘#{cur_cnt - cur_discount}元"
            PromotionCount.range_discount_by_user_reduce(user_id,cur_discount)
        end
    end

    #滿額折X元，限定每月全站限定額度
    
    def monthly_range_discount_by_site(test_flag = false)
        cur_month = Time.now.strftime('%Y%m')
        if test_flag
            discount_obj = Promotion::MONTHLY_RANGE_DISCOUNT_BY_SITE.fetch("M#{cur_month}".to_sym).
            select{|x| 
                cur_sum >= x.range_start and (x.range_end.blank? or cur_sum < x.range_end)
            }.first 
        end
        cur_cnt = PromotionCount.check_monthly_check_range_discount_by_site(cur_month)
        if cur_cnt > 0 and discount_obj.present?
            cur_discount = discount_obj.rebate
            cur_discount = cur_cnt if cur_discount > cur_cnt
            self.discount += cur_discount
            self.msg << cur_msg = "滿額#{discount_obj.range_start}折#{discount_obj.rebate}元共折#{cur_discount}#{'已達上限'if cur_discount == cur_cnt}，個人優惠剩餘#{cur_cnt - cur_discount}元"
            PromotionCount.monthly_range_discount_by_site_reduce(cur_month,cur_discount)
        end
    end
end