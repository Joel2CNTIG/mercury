require_relative 'request.rb'

class Router
    attr_accessor :list
    def initialize()
        @list = []
    end

    def get(route_string, &blk)
        data = construct_get_and_post(route_string)
        @list << {symbols: data[0], route: Regexp.new(data[1]), block: blk, method: "GET"}
    end

    def post(route_string, &blk)
        data = construct_get_and_post(route_string)
        @list << {symbols: data[0], route: Regexp.new(data[1]), block: blk, method: "POST"}
    end

    def match_route(visited_route, method)
        matching = @list.find {|element| element[:method] == method && element[:route].match?(visited_route)}
        if matching == nil
            return [false, {}]
        end
        matching_route = matching[:route]
        params = {}
        i = 1
        j = 0
        params_array = visited_route.match(matching_route)
        while i < params_array.length
            params[matching[:symbols][j]] = params_array[i]
            i += 1
            j += 1
        end
        return [@list.find_index(matching), params]
    end

    private

    def construct_get_and_post(str)
        split_string = str.split("/")
        symbols = []
        split_string.each do |section|
            if section[0] == ":"
                section.slice!(0)
                symbols << section.to_sym
            end
        end
        route = str.gsub(/:\w+/, '(\w+)')
        route += "$"
        return [symbols, route]
    end
end