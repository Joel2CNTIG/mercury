class Router
    attr_accessor :route_list, :params
    def initialize
        @route_list = []
    end

    def add_route(route_string)
        @route_list << route_string
    end

    def match_route(route_string)
        j = 0
        while j < @route_list.length
            route_split = @route_list[j].split("/")
            route_string_split = route_string.split("/")
            i = 0
            while i < route_split.length
                if route_split[i][0] == ":"
                    route_split[i] = route_string_split[i]
                end
                i += 1
            end
            if route_split == route_string_split
                return j
            end
            j += 1
        end
        return false
    end

    def collect_params(route_string)
        params = {}
        route = @route_list[match_route(route_string)]
        route_split = route.split("/")
        route_string_split = route_string.split("/")
        route_split.delete_at(0)
        route_string_split.delete_at(0)
        i = 0
        while i < route_string_split.length
            if route_split[i][0] == ":"
                route_split[i].slice!(0)
                params[route_split[i].to_sym] = route_string_split[i]
            end
            i += 1
        end
        params
    end
end