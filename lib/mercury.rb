class Router

    def initialize
        @route_list = []
    end
    
    def add_route(route_string)
        @route_list << (route_string)
    end

    def match_route(route_string)
        @route_list.include?(route_string)
    end

end

class Request

    attr_reader :method, :resource, :version, :headers, :params
    def initialize(rq_string)
        @data = rq_string.split("\n")
        row1 = @data[0]
        @row1_split = row1.split(" ")
        @method = @row1_split[0]
        @resource = @row1_split[1]
        @version = @row1_split[2]
        @headers = get_headers
        @params = get_params
    end

    private

    def is_params?(str)
        if str.include?("?") || str.include?("=")
            return true
        end
        return false
    end

    def split_by_char(str)
        str.split(/[?,=,&]/)
    end

    def get_params
        params = {}
        contents = split_by_char(@row1_split[1])
        i = 2
        while i <= contents.length
            params[contents[i-1]] = contents[i]
            i += 2
        end
        if is_params?(@data[@data.length - 1])
            contents = split_by_char(@data[@data.length - 1])
            i = 1
            while i <= contents.length
                params[contents[i-1]] = contents[i]
                i += 2
            end
        end
        params
    end

    def construct_header_formated_string_from_arr(arr)
        str = ""
        i = 1
        while i < arr.length
            str += arr[i]
            j = i
            until arr[j + 1] == nil
                str += " #{arr[j + 1]}"
                j += 1
            end
            unless i = arr.length-1
                str += ", "
            end
            i += 1
        end
        return str
    end

    def get_headers
        headers = {}
        @data.drop(1).each do |element|
            if element.include?(":")
                element = element.split(" ")
                header_string = construct_header_formated_string_from_arr(element)
                unless element[0] == nil
                    headers[element[0]] = header_string
                end
            end
        end
        headers
    end
end

request_string = File.read("spec/files/get-fruits-with-filter.request.txt")
request = Request.new(request_string)
p request.headers