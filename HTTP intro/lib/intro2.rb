class Request
    def initialize(rq_string)
        @data = rq_string.split("\n")
        row1 = @data[0]
        @row1_split = row1.split(" ")
    end

    def method
        @method = @row1_split[0]
    end

    def resource
        @resource = @row1_split[1]
    end

    def version
        @version = @row1_split[2]
    end

    def params
        params = {}
        if @row1_split[1].include?("?")
            resource = @row1_split[1].split("?")
            contents = resource[1].split(/[=,&]/)
            i = 1
            while i <= contents.length
                params[contents[i-1]] = contents[i]
                i += 2
            end
        elsif @data[@data.length-1].include?("=")
            contents = @data[@data.length - 1].split(/[=,&]/)
            i = 1
            while i <= contents.length
                params[contents[i-1]] = contents[i]
                i += 2
            end
        end
        @params = params
    end

    def headers
        unused, *used = @data
        headers = {}
        used.each do |element|
            if element.include?(":")
                element = element.split(" ")
                i = 1
                header_params = []
                while i < element.length
                    header_params << element[i]
                    i += 1
                end
                header_string = ""
                i = 0
                while i < header_params.length
                    header_string += header_params[i]
                    unless i == (header_params.length-1)
                        header_string += " "
                    end
                    i += 1
                end
                unless element[0] == nil
                    headers[element[0]] = header_string
                end
            end
        end
        @headers = headers
    end
end

request_string = File.read("spec/files/get-index.request.txt")
request = Request.new(request_string)
p request.headers