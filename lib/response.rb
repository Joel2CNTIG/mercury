require_relative 'request.rb'
require_relative 'router.rb'

class Response 

    attr_reader :status, :header_arr, :param_arr, :html

    def initialize(request, router, session)
        @router = router
        @request = request
        @session = session
        @list = router.list
    end

    def status(route)
        if @router.match_route(route) != false
            status = @request.version + "200 OK \r\n"
        else
            status = @request.version + "404 NOT FOUND \r\n"
        end
        return status
    end

    def html(route)
        if status(route) == @request.version + "200 OK \r\n"
            pos = @router.match_route(route)
            params = @list[pos][:params]
            html = "<html> <head> <meta charset='UTF-8'> </head> #{@list[pos][:code]} </html>"
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
        @session.print status(@request.resource)
        @session.print content_length(html)
        @session.print content_type(@request)
        @session.print "\r\n"
        @session.print html
        @session.close
    end
end