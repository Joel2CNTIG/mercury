require 'socket'
require_relative 'request.rb'
require_relative 'router.rb'
require_relative 'response.rb'
require 'debug'

class HTTPServer

    def initialize(port)
        @port = port
        @location = nil
    end

    def redirect(url)
        location = url
    end

    def html(path, params)
        html = File.read(path)
        params.each {|key, value| 
            str = '#'
            str += "{params[:#{key}]}"
            html = html.gsub(str, value)
        }
        return html
    end

    def start(&blk)
        server = TCPServer.new(@port)
        puts "Listening on #{@port}"
        router = Router.new

        router.get('/error') do |params|
            "<h1> error! <h1>"
        end
        router.get('/hej/:id') do |params|
            html = html('lib/html/start.html', params)
            #"<form action='/hej/#{params[:id]}/post-print_nbr' method='post'>
            #<input type='text' name='first_name' placeholder='first name'> 
            #<input type='password' name='pwd' placeholder='password'>
            #<input type='submit' value='submit'></form>"
        end 

        router.post('/hej/:id/post-print_nbr') do |params|
            f = File.open('test.txt', 'w')
            f.puts(params[:first_name])
            f.close
            redirect("/hej/#{params[:id]}/banan")
        end

        while session = server.accept
            data = ""

            #om det är en post-request (form-url-encoded)
            # läs en rad till

            
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
            response = Response.new(request, router, session)
            response.print
            @location = nil
        end
    end
end

server = HTTPServer.new(4567)
server.start