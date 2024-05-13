require_relative 'request.rb'

class Router
    attr_accessor :list

    # Initializes instance variables
    #
    def initialize()
        @list = []
    end

    # Determines which url to redirect to
    #
    # @param [String] selected url
    def redirect(url)
        return url
    end

    # Builds html string with params from path to html file
    #
    # @param [String] path to file
    # @param [Hash] hash with params
    # @return [String] html string
    def html(path, params)
        html = File.read("./public/#{path}")
        params.each {|key, value| 
            str = '#'
            str += "{params[:#{key}]}"
            html = html.gsub(str, value)
        }
        return html
    end

    # Constructs get route
    #
    # @param [String] route string
    # @param [Block] block
    # @see #construct_get_and_post
    def get(route_string, &blk)
        data = construct_get_and_post(route_string)
        @list << {symbols: data[0], route: Regexp.new(data[1]), block: blk, method: "GET"}
    end

    # Constructs post route
    #
    # @param [String] route string
    # @param [Block] block
    # @see #construct_get_and_post
    def post(route_string, &blk)
        data = construct_get_and_post(route_string)
        @list << {symbols: data[0], route: Regexp.new(data[1]), block: blk, method: "POST"}
    end

    # checks if route exists and constructs params
    #
    # @param [String] visited route
    # @param [Block] method (get or post)
    # @return [Array] array with matching route and params, alternatively false and empty hash if no routes match
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
        return [matching, params]
    end

    private

    # Builds get and post routes
    # @param [String] input route to construct for
    # @return [Array] param symbols and gsubbed route

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