class OrderController < ApplicationController
    def index
        @products = ::Product::PRODUCT_HASH
    end
    
end
