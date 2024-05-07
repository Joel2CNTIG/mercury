class Request
    attr_reader :method, :resource, :version, :headers, :params

    # Initializes and saves instance variables, runs private methods
    #
    # @param [String] string of request data 
    def initialize(rq_string)
        @data = rq_string.split("\r\n")
        row1 = @data[0]
        @row1_split = row1.split(" ")
        @method = @row1_split[0]
        @resource = @row1_split[1]
        @version = @row1_split[2]
        @headers = get_headers
        @params = get_params
    end

    private

    # Checks if string matches structure of params
    #
    # @param [String] string to check
    # @return [Boolean] true if string matches- params, otherwise false
    def is_params?(str)
        if str.include?("?") || str.include?("&")
            return true
        end
        return false
    end

    # Splits input string when certain characters are met
    #
    # @param [String] string to split
    # @return [String] string split by specified characters
    def split_by_char(str)
        str.split(/[?,=,&,%]/)
    end

    # Gathers any parameters within request
    #
    # @return [Hash] hash with collected parameters
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
                params[contents[i-1]].gsub!("+", " ")
                i += 2
            end
        end
        params
    end

    # Constructs string with HTTP headers-syntax from array
    #
    # @param [Array] input array
    # @return [String] header-formated string
    def construct_header_formated_string_from_arr(arr)
        str = ""
        i = 1
        while i < arr.length
            arr[i].slice!(0)
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

    # Collects headers within request
    #
    # @return [Hash] hash with headers
    def get_headers
        headers = {}
        @data.drop(1).each do |element|
            if element.include?(":")
                element = element.split(":")
                header_string = construct_header_formated_string_from_arr(element)
                unless element[0] == nil
                    headers[element[0]] = header_string
                end
            end
        end
        headers
    end
end
