require_relative 'request.rb'
require_relative 'router.rb'

class Response 

    # Initialize instance variables and runs main method
    #
    # @param [String] string of request data
    # @param [Router] router
    # @param [Session] current session
    # @see #build_response_and_print
    # @see #content_type
    def initialize(request, router, session)
        @router = router
        @request = request
        @session = session
        @ok = @request.version + " 200 OK \r\n"
        @not_ok = @request.version + " 404 NOT FOUND \r\n"
        @type = content_type()
        build_response_and_print()
    end

    # Main method, runs all other methods to get response information, then prints it
    #
    # @see #content
    # @see #static_resource
    # @see #content_length
    # @see Router#match_route
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
        unless @request.method == "POST" && @location == nil
            content_length = content_length(content)
        end
        if @location
            status = "#{@request.version}" + " 302 FOUND \r\n"
            @session.print status
            @session.print "Location: #{@location}"
            @session.print "\r\n"
        else
            unless @request.method == "POST"
                @session.print status
                @session.print content_length
                @session.print @type[0]
                @session.print "\r\n"
                @session.print content
            end
        end
        @session.close
    end

    private

    # Builds content from route
    #
    # @see Router#match_route
    # @param [String] selected route
    # @return [String] html code or redirect depending on post or get
    def content(route)
        method = @request.method
        route_info = @router.match_route(route, method)[0]
        params = @router.match_route(route, method)[1]
        request_params = @request.params
        request_params.each do |param|
            symbol = param[0].to_sym
            params[symbol] = param[1]
        end
        code = route_info[:block].call(params)
        if method == "GET"
            if File.exist?("public/html/layout.html")
                html = File.read("public/html/layout.html")
                html.gsub!("== yield", code)
                return html
            else
                return code
            end
        elsif method == "POST"
            @location = code
            return code
        end
    end

    # Finds image or css/js file in public map
    #
    # @param [string] route string
    # @return [String] contents of the file
    def static_resource(route)
        if @type[1]
            return File.open("./public#{@request.resource}", "rb").read
        elsif @type[0] == "content-type: text/css \r\n" || @type[0] == "content-type: text/javascript \r\n"
            return File.read("./public#{@request.resource}")
        end
    end

    # Determines length of content
    #
    # @param [String] content string
    # @return [Integer] content length
    def content_length(input)
        c_length = "content-length: #{input.length} \r\n"
        if @type[1]
            c_length = "content-length: #{File.open("./public#{@request.resource}", "rb").read.length} \r\n"
        end
        return c_length
    end

    # Determines type of content
    #
    # @return [Array] String with content type header and boolean to determine if content is an image
    def content_type()
        image = false
        headers = @request.headers
        accept = headers["Accept"]
        type = accept.split(",").first
        c_type = "content-type: #{type} \r\n"
        if @request.resource.downcase.end_with?(".png")
            c_type = "content-type: image/png \r\n"
            image = true
        elsif @request.resource.downcase.end_with?(".jpg") || @request.resource.downcase.end_with?(".jpeg")
            c_type = "content-type: image/jpeg \r\n"
            image = true
        elsif @request.resource.downcase.end_with?(".gif")
            c_type = "content-type: image/gif \r\n" 
            image = true
        end
        return [c_type, image]
    end
end