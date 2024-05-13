require_relative "lib/request.rb"
require_relative "lib/router.rb"
require_relative "lib/response.rb"
require_relative "lib/HTTPserver.rb"

router = Router.new
router.get("/hej_bre/:id") do |params|
    id = params[:id]
    "<h1> jag är #{id} år gammal </h1>" 
end

router.get('/mamma/:age/:stench') do |params|
    "<h1> Din Morsa är #{params[:age]} år gammal och luktar #{params[:stench]}! <h1>"
end

router.get('/error') do |params|
    "<h1> error! <h1>"
end

router.get('/hej/:id') do |params|
    html = router.html('html/start.html', params)
end 

router.post('/hej/:id/post-print_nbr') do |params|
    f = File.open('test.txt', 'w')
    f.puts("user id: #{params[:id]}.")
    f.puts("username: #{params[:first_name]}")
    f.puts("password: #{params[:pwd]}")
    f.puts("\n")
    f.close
    router.redirect("/hej/7")
end


HTTPServer.new(router, 4567).start


