require 'socket'
require_relative 'request.rb'
require_relative 'router.rb'
require_relative 'response.rb'

class HTTPServer

    def initialize(port)
        @port = port
    end

    def start
        server = TCPServer.new(@port)
        puts "Listening on #{@port}"
        router = Router.new
        router.add_route('/hej/:id') do
            "<h1> Välkommen till min hemsida </h1>
            <h2> Jag gillar grillkorv och är #{} år gammal </h2>"
        end

        while session = server.accept
            data = ""
            while line = session.gets and line !~ /^\s*$/
                data += line
            end
            puts "RECEIVED REQUEST"
            puts "-" * 40
            puts data
            puts "-" * 40 

            request = Request.new(data)
            #Sen kolla om resursen (filen finns)
            response = Response.new(request, router, session)
            
            response.print
        end
    end
end

server = HTTPServer.new(4567)
server.start