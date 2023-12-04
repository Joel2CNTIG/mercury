require_relative "lib/mercury.rb"

request_string = File.read("spec/files/get-index.request.txt")
request = Request.new(request_string)
router = Router.new
router.add_route('/fortnite')
router.add_route('/fortnite/:id')
p router.match_route('/fortnite/5')
p request.method
p request.resource
p request.version
p request.headers
p request.params
