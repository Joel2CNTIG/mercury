require_relative "lib/request.rb"
require_relative "lib/router.rb"
require_relative "lib/response.rb"

#request_string = File.read("spec/files/get-index.request.txt")
#request = Request.new(request_string)
router = Router.new
request = Request.new(File.read("./spec/files/post-login.request.txt"))
response = Response.new(request, router)
router.add_route('/fortnite') do
    "<h1> HEllo! </h1>
        <h2> Slob on my knob </h2>"
end
p response.print_headers
p response.print_params
p response.html('/fortnite')
#router.add_route('/fortnite/:id')
#p router.match_route('/fortnite/5')
#p request.method
#p request.resource
#p request.version
#p request.headers
#p request.params



