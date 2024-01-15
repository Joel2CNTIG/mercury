require_relative "lib/request.rb"
require_relative "lib/router.rb"

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
router.add_route("/fortnite")
router.add_route("/fortnite/:id")
router.add_route("/:id/fortniteabc/:nbr/:var")
p router.collect_params("/7/fortniteabc/4/aaa")

