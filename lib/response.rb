require_relative 'request.rb'
require_relative 'router.rb'

class Response 

    attr_reader :status, :header_arr, :param_arr, :html

    def initialize(request, router, session)
        @router = router
        @request = request
        @session = session
        @list = router.list
        @redirect = true
    end

    def status(route)
        if @router.redirection != nil
            status = @request.version + " 308 Permanent Redirect \r\n"
            @request.headers["Location"] = @router.redirection
        elsif @router.match_route(route, @request.method)[0] != false
            status = @request.version + " 200 OK \r\n"
        else
            status = @request.version + " 404 NOT FOUND \r\n"
        end
        
        return status
    end

    def html(route)
        unless status(route) == @request.version + " 404 NOT FOUND \r\n"
            method = @request.method
            if @router.match_route(route, method)[0] != false
                pos = @router.match_route(route, method)[0]
                params = @router.match_route(route, method)[1]
                request_params = @request.params
                request_params.each do |param|
                    symbol = param[0].to_sym
                    params[symbol] = param[1]
                end
                code = @list[pos][:block].call(params)
                if method == "GET"
                    html = "<html> <head> <meta charset='UTF-8'> </head> #{code} </html>"
                elsif method == "POST"
                    html = "#{code}"
                end
            else
                html = "<html> <head> <meta charset='UTF-8'> </head> <h1> Route not found! :( </h1> </html>"
            end
        else
            html = "<html> <head> <meta charset='UTF-8'> </head> <h1> Route not found! :( </h1> </html>"
        end
    end

    def content_length(text)
        "content-length: #{text.length} \r\n"
    end

    def content_type(request)
        headers = request.headers
        accept = headers["Accept"]
        type = accept.split(",").first
        "content-type: #{type} \r\n"
    end

    def print
        html = html(@request.resource)
        content_type(@request)
        p status(@request.resource)
        @session.print status(@request.resource)
        @session.print content_length(html)
        @session.print content_type(@request)
        @session.print "\r\n"
        @session.print html
        @session.close
    end
end