require 'socket'
require_relative 'request.rb'
require_relative 'router.rb'
require_relative 'response.rb'
require 'debug'

class HTTPServer

    # Initializes and saves instance variables
    #
    # @param [Router] router to be utilized
    # @param [Integer] port number of server
    def initialize(router, port)
        @port = port
        @router = router
    end

    # Main method. Receives request and calls on other classes to process it
    #
    def start()
        server = TCPServer.new(@port)
        puts "Listening on #{@port}"

        while session = server.accept
            data = ""
            
            while line = session.gets
                unless line !~ /^\s*$/
                    if data.start_with?("POST")
                        index = data.index("Content-Length") + 16
                        length = ""
                        while data[index] != "\r"
                            length += data[index]
                            index += 1
                        end
                        length = length.to_i
                        data += session.gets(length)
                    end
                    break
                end
                data += line
            end
            puts "RECEIVED REQUEST"
            puts "-" * 40
            puts data
            puts "-" * 40 
            request = Request.new(data)
            response = Response.new(request, @router, session)
        end
    end
end