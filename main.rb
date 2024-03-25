require_relative "lib/request.rb"
require_relative "lib/router.rb"
require_relative "lib/response.rb"
require_relative "lib/HTTPserver.rb"

server = HTTPServer.new(4567)
server.start do 
    router = Router.new
    router.add_route("/hej_bre/:id") do |params|
        id = params[:id]
        "<h1> jag är #{id} år gammal </h1>" 
    end
end



