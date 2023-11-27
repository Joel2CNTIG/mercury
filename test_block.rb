class Array
    def mappa(&blk)
        if block_given?
            new_arr = []
            i = 0
            while i < self.length
                new_arr << yield(self[i])
                i += 1
            end
            return new_arr
        else
            p self
        end
    end
end

def grilla(korv, &blk)
    if block_given?
        puts "#{korv} med #{yield('ketchup')}"
    else
        puts "trökig #{korv}"
    end
end

grilla("korv") do |x|
    "senap och #{x}"
end

arr = [1,2,3]
p arr.mappa
p arr.mappa {|val| val * 3}

p arr.shift
