require_relative "lib/mercury.rb"

request_string = File.read("spec/files/get-index.request.txt")
request = Request.new(request_string)
p request.method
p request.resource
p request.version
p request.headers
p request.params