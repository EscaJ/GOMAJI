class PromotionCount
    #次數遞減
    def self.range_discount_by_site_reduce
        #無DB環境故暫用文字文件取代
        self.cnt_reduce('./range_discount_by_site.txt')
    end

    #回傳判斷結果
    def self.check_range_discount_by_site
        #無DB環境故暫用文字文件取代
        return self.get_cnt('./range_discount_by_site.txt')
    end

    #次數遞減
    def self.range_discount_by_user_reduce(user_id,discount)
        #無DB環境故暫用文字文件取代
        self.cnt_reduce("./range_discount_by_user_#{user_id}.txt",discount)
    end

    #回傳判斷結果
    def self.check_range_discount_by_user(user_id)
        #無DB環境故暫用文字文件取代
        return self.get_cnt("./range_discount_by_user_#{user_id}.txt")
    end

    #次數遞減
    def self.monthly_range_discount_by_site_reduce(month,discount)
        #無DB環境故暫用文字文件取代
        self.cnt_reduce("./range_discount_by_site_M#{month}.txt",discount)
    end

    #回傳判斷結果
    def self.check_monthly_check_range_discount_by_site(month)
        #無DB環境故暫用文字文件取代
        return self.get_cnt("./range_discount_by_site_M#{month}.txt")
    end
    

    def self.cnt_reduce(path,reduce = 1)
        file = File.open(path,'r')
        range_discount_count = file.readlines.first.to_i
        file.close
        File.write(path, "#{range_discount_count-reduce}", mode: 'w')
    end
    def self.get_cnt(path)
        file = File.open(path,'r')
            range_discount_count = file.readlines.first.to_i
        file.close
        return range_discount_count
    end
    def self.generate_person_txt(user_id)
        cnt = self.get_cnt("./range_discount_by_user_#{user_id}.txt") rescue nil
        File.open("./range_discount_by_user_#{user_id}.txt", "w") { |f| f.write "5000" } #預設折價額度為5000
    end
end