require 'rails_helper'

RSpec.describe Promotion, type: :model do
  # 訂單滿 X 元折 Z %
  # 特定商品滿 X 件折 Y 元
  # 訂單滿 X 元贈送特定商品
  # 訂單滿 X 元折 Y 元,此折扣在全站總共只能套用 N 次
  # (加分題)訂單滿 X 元折 Z %,折扣每人只能總共優惠 N 元
  # (加分題)訂單滿 X 元折 Y 元,此折扣在全站每個月折扣上限為 N 元
  #pending "add some examples to (or delete) #{__FILE__}"
  it "訂單滿 X 元折 Z %" do
    obj = Promotion.new([{name: "電腦螢幕", nums: "2"}, {name: "音響", nums: "0"}],12000)
    obj.range_discount(true)
    expect(obj.discount).to eq(1320)    # 驗算折扣金額與回傳的折扣是否相符
  end

  it "訂單滿 X 元折 Z %" do
    obj = Promotion.new([{name: "電腦螢幕", nums: "2"}, {name: "音響", nums: "0"}],21111)
    obj.range_discount(true)
    expect(obj.discount).to eq(6333)    # 驗算折扣金額與回傳的折扣是否相符
  end

  it "特定商品滿 X 件折 Y 元" do
    obj = Promotion.new([{name: "電腦螢幕", nums: "2"}, {name: "音響", nums: "0"}],12000)
    obj.product_discount(true)
    expect(obj.discount).to eq(500)    # 達成一項促銷條件，檢查結果應該要是 500
  end

  it "特定商品滿 X 件折 Y 元" do
    obj = Promotion.new([{name: "電腦螢幕", nums: "2"}, {name: "音響", nums: "1"}],12000)
    obj.product_discount(true)
    expect(obj.discount).to eq(800)    # 達成兩項促銷條件，檢查結果應該要是 800
  end

  it "訂單滿 X 元贈送特定商品" do
    obj = Promotion.new([{name: "電腦螢幕", nums: "2"}, {name: "音響", nums: "1"}],12000)
    obj.range_free_gift(true)
    #puts obj.free_gifts.inspect
    expect(obj.free_gifts).to eq([{name: "滑鼠墊",nums: 1},{name: "鍵盤滑鼠",nums: 1}])    # 滿足兩項滿額贈品條件
  end

  it "訂單滿 X 元折 Y 元,此折扣在全站總共只能套用 N 次" do
    cur_cnt = PromotionCount.get_cnt('./range_discount_by_site.txt')
    File.open("./range_discount_by_site.txt", "w") { |f| f.write "100" } #測試可折價次數為100
    (1..101).each do |h|
      obj = Promotion.new([{name: "電腦螢幕", nums: "2"}, {name: "音響", nums: "1"}],12000)
      obj.range_discount_by_site(true)
      if h != 101
        #puts obj.discount
        expect(obj.discount).to eq(400) #1 ~ 100次折價都是400
      else
        expect(obj.discount).to eq(0)    #第101次已無折扣額度
      end
    end
    File.open("./range_discount_by_site.txt", "w") { |f| f.write cur_cnt } #回復為測試前的額度
  end

  it "(加分題)訂單滿 X 元折 Z %,折扣每人只能總共優惠 N 元" do
    cur_cnt = PromotionCount.get_cnt("./range_discount_by_user_testuser.txt")
    File.open("./range_discount_by_user_testuser.txt", "w") { |f| f.write "5000" } #測試可折價額度為5000
    (1..2).each do |h|
      obj = Promotion.new([{name: "電腦螢幕", nums: "2"}, {name: "音響", nums: "1"}],20000)
      obj.range_discount_by_user('testuser',true)
      if h == 1
        expect(obj.discount).to eq(4000)  #第1次額度足夠
      else
        expect(obj.discount).to eq(1000)    #第2次只剩1000額度
      end
    end
    File.open("./range_discount_by_user_testuser.txt", "w") { |f| f.write cur_cnt } #回復為測試前的額度
  end

  it "(加分題)訂單滿 X 元折 Y 元,此折扣在全站每個月折扣上限為 N 元" do
    cur_cnt = PromotionCount.get_cnt("./range_discount_by_site_M#{Time.now.strftime('%Y%m')}.txt") rescue 0
    File.open("./range_discount_by_site_M#{Time.now.strftime('%Y%m')}.txt", "w") { |f| f.write "5000" } #測試可折價次數為100
    (1..13).each do |h|
      obj = Promotion.new([{name: "電腦螢幕", nums: "2"}, {name: "音響", nums: "1"}],12000)
      obj.monthly_range_discount_by_site(true)
      if h != 13
        #puts obj.discount
        expect(obj.discount).to eq(400) #1 ~ 12次折價都是400
      else
        expect(obj.discount).to eq(200)    #第13次已無折扣額度
      end
    end
    File.open("./range_discount_by_site_M#{Time.now.strftime('%Y%m')}.txt", "w") { |f| f.write cur_cnt } #回復為測試前的額度
  end
  
end
