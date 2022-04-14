class Hash
    def method_missing(m,*args,&block)
        if self.keys.include?(m.to_sym)
            return self.fetch(m.to_sym)
        else
            super
        end
        
    end
end