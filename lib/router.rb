require_relative 'request.rb'

class Router
    attr_accessor :list
    def initialize()
        @list = []
    end

    def add_route(route_string, &blk)
        split_string = route_string.split("/")
        symbols = []
        split_string.each do |section|
            if section[0] == ":"
                section.slice!(0)
                symbols << section.to_sym
            end
        end
        route = route_string.gsub(/:\w+/, "/(\w+)/")
        @list << {symbols: symbols, route: route, code: blk}
    end

    def match_route(visited_route)
        pos = @list.find(visited_route).first
        p pos
        if pos == false
            return false
        end
        p pos[:route].match?(visited_route)
        params = {}
        return pos
    end
end