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

    def print
        html = html(@request.resource)
        if @location
            status = "#{@request.version}" + " 302 FOUND \r\n"
            @session.print status
            @session.print "Location: #{@location}"
            @session.print "\r\n"
        else
            @session.print status(@request.resource)
            @session.print content_length(html)
            @session.print content_type(@request)
            @session.print "\r\n"
            @session.print html
        end
        @session.close
    end

    private

    def status(route)
        ok = @request.version + " 200 OK \r\n"
        not_ok = @request.version + " 404 NOT FOUND \r\n"
        if @router.match_route(route, @request.method)[0] != false
            status = ok
        else
            status = not_ok
        end
        if is_img(@request) && File.file?(".#{@request.resource}")
            status = ok
        end
        if is_css(@request)
            status = ok
        end
        return status
    end

    def is_css(request)
        resource = request.resource
        while resource != ""
            if content_type(request) == "content-type: text/css \r\n" && File.file?(".#{resource}")
                return true
            end
            resource = resource[1..-1]
        end
        return false
    end

    def css_from(resource)
        while resource != ""
            if content_type(resource) == "content-type: text/css \r\n" && File.file?(".#{resource}")
                return ".#{resource}"
            end
            resource = resource[1..-1]
        end
    end

    def is_img(request)
        return content_type(request).start_with?("content-type: image")
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
                    html = code
                    @location = code
                end
            elsif is_img(@request) && status(route) == @request.version + " 200 OK \r\n"
                html = File.open(".#{@request.resource}", "rb").read
            elsif is_css(@request) && status(route) == @request.version + " 200 OK \r\n"
                html = File.read(css_from(route))
            else
                html = "<html> <head> <meta charset='UTF-8'> </head> <h1> Route not found! :( </h1> </html>"
            end
        else
            html = "<html> <head> <meta charset='UTF-8'> </head> <h1> Route not found! :( </h1> </html>"
        end
    end

    def content_length(input)
        c_length = "content-length: #{input.length} \r\n"
        if is_img(@request) && @request.resource != "/favicon.ico"
            c_length = "content-length: #{File.open(".#{@request.resource}", "rb").read.length} \r\n"
        end
        return c_length
    end

    def content_type(request)
        if request.class.name == "String" && request.downcase.end_with?(".css")
            return "content-type: text/css \r\n"
        end
        headers = request.headers
        accept = headers["Accept"]
        type = accept.split(",").first
        c_type = "content-type: #{type} \r\n"
        if request.resource.downcase.end_with?(".png")
            c_type = "content-type: image/png \r\n"
        elsif request.resource.downcase.end_with?(".jpg") || @request.resource.downcase.end_with?(".jpeg")
            c_type = "content-type: image/jpeg \r\n"
        elsif request.resource.downcase.end_with?(".gif")
            c_type = "content-type: image/gif \r\n" 
        end
        return c_type
    end
end