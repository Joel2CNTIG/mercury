require_relative 'request.rb'
require_relative 'router.rb'

class Response 
    attr_reader :status, :header_arr, :param_arr, :html

    def initialize(request, router, session)
        @router = router
        @request = request
        @session = session
        @list = router.list
        @ok = @request.version + " 200 OK \r\n"
        @not_ok = @request.version + " 404 NOT FOUND \r\n"
        @type = type_of_content(request)
        build_response_and_print()
    end

    def build_response_and_print()
        if @router.match_route(@request.resource, @request.method)[0] != false
            status = @ok
            content = content(@request.resource)
        elsif File.file?("./public#{@request.resource}")
            status = @ok
            content = static_resource(@request.resource)
        else
            status = @not_ok
            content = html = "<html> <head> <meta charset='UTF-8'> </head> <h1> Route not found! :( </h1> </html>"
        end
        content_length = content_length(content)
        content_type = content_type(@request)
        #p status, content, content_length, content_type
        if @location
            status = "#{@request.version}" + " 302 FOUND \r\n"
            @session.print status
            @session.print "Location: #{@location}"
            @session.print "\r\n"
        else
            @session.print status
            @session.print content_length
            @session.print content_type
            @session.print "\r\n"
            @session.print content
        end
        @session.close
    end

    private

    def content(route)
        method = @request.method
        pos = @router.match_route(route, method)[0]
        params = @router.match_route(route, method)[1]
        request_params = @request.params
        request_params.each do |param|
            symbol = param[0].to_sym
            params[symbol] = param[1]
        end
        code = @list[pos][:block].call(params)
        if method == "GET"
            return "<html> <head> <meta charset='UTF-8'> </head> #{code} </html>"
        elsif method == "POST"
            @location = code
            return code
        end
    end

    def static_resource(route)
        if @type == "img"
            return File.open("./public#{@request.resource}", "rb").read
        elsif @type == "css" || @type == "js"
            return File.read("./public#{@request.resource}")
        end
    end

    def type_of_content(request)
        if content_type(request).start_with?("content-type: image") && !content_type(request).end_with?("avif \r\n")
            return "img"
        elsif content_type(request).start_with?("content-type: text/css")
            return "css"
        elsif content_type(request).start_with?("content-type: text/javascript")
            return "js"
        end
    end

    def content_length(input)
        c_length = "content-length: #{input.length} \r\n"
        if @type == "img"
            c_length = "content-length: #{File.open("./public#{@request.resource}", "rb").read.length} \r\n"
        end
        return c_length
    end

    def content_type(request)
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