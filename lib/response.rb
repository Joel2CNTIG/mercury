require_relative 'request.rb'
require_relative 'router.rb'

class Response 

    def initialize(request, router)
        @router = router
        @request = request
    end

    def print_status
        status = @request.version + "200"
    end

    def print_headers
        headers = @request.headers
        header_arr = []
        headers.each do |header|
            header_str = "#{header[0]}: #{header[1]}\r\n"
            header_arr << header_str
        end
        header_arr
    end

    def print_params
        params = @request.params
        param_arr = []
        params.each do |param|
            param_str = "#{param[0]}: #{param[1]}\r\n"
            param_arr << param_str
        end
        if param_arr == []
            param_arr << "\r\n"
        end
        param_arr
    end

    def html(route)
        pos = @router.match_route(route)
        unless pos == false
            html = @router.code_list[pos]
        end
    end
end