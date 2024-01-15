require './lib/mercury.rb'

describe 'Request' do

    it 'parses the get-index' do
        headers =  {"Host:"=>"developer.mozilla.org", "Accept-Language:"=>"fr"}
        params = {}
        @request = Request.new(File.read("./spec/files/get-index.request.txt"))
        _(@request.method).must_equal "GET"
        _(@request.resource).must_equal "/"
        _(@request.version).must_equal "HTTP/1.1"
        _(@request.headers).must_equal headers
        _(@request.params).must_equal params
    end

    it 'parses the get-examples' do
        headers = {"Host:" => "example.com", "User-Agent:" => "ExampleBrowser/1.0", "Accept-Encoding:" => "gzip, deflate", "Accept:" => "*/*"}
        params = {}
        @request = Request.new(File.read("./spec/files/get-examples.request.txt"))
        _(@request.method).must_equal "GET"
        _(@request.resource).must_equal "/examples"
        _(@request.version).must_equal "HTTP/1.1"
        _(@request.headers).must_equal headers
        _(@request.params).must_equal params
    end

    it 'parses the get-fruits-with-filter' do
        headers = {"Host:" => "fruits.com", "User-Agent:" => "ExampleBrowser/1.0", "Accept-Encoding:" => "gzip, deflate", "Accept:" => "*/*"}
        params = {"type" => "bananas", "minrating" => "4"}
        @request = Request.new(File.read("./spec/files/get-fruits-with-filter.request.txt"))
        _(@request.method).must_equal "GET"
        _(@request.resource).must_equal "/fruits?type=bananas&minrating=4"
        _(@request.version).must_equal "HTTP/1.1"
        _(@request.headers).must_equal headers
        _(@request.params).must_equal params
    end

    it 'parses the post-login' do
        headers = {"Host:" => "foo.example", "Content-Type:" => "application/x-www-form-urlencoded", "Content-Length:" => "39"}
        params = {"username" => "grillkorv", "password" => "verys3cret!"}
        @request = Request.new(File.read("./spec/files/post-login.request.txt"))
        _(@request.method).must_equal "POST"
        _(@request.resource).must_equal "/login"
        _(@request.version).must_equal "HTTP/1.1"
        _(@request.headers).must_equal headers
        _(@request.params).must_equal params
    end

    it 'parses the add route' do
        router = Router.new()
        router.add_route("hej")
        router.must_equal #<Router:0x000002c0b6349c88 @route_list=["hej"]>
    end

    it 'parses the match route' do
        router = Router.new()
        router.add_route("/fortnite")
        router.add_route("/fortnite/:id")
        router.add_route("/:id/fortniteabc/:nbr/:var")
        (router.match_route("/fortnite")).must_equal true
        (router.match_route("/fortnite/8")).must_equal true
        (router.match_route("/7/fortniteabc/14/hej")).must_equal true
    end
end
    





