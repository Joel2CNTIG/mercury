require_relative "lib/mercury.rb"

#request_string = File.read("spec/files/get-index.request.txt")
#request = Request.new(request_string)
#router = Router.new
#router.add_route('/fortnite')
#router.add_route('/fortnite/:id')
#p router.match_route('/fortnite/5')
#p request.method
#p request.resource
#p request.version
#p request.headers
#p request.params

router = Router.new()
p router
router.add_route("forre/:id/tjo/:hej/pro") do
    puts "woot"
end
router.add_route("hej/dig")
p router.match_route("forre/6/tjo/8/pro")