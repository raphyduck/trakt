module Trakt
  module Connection
    def initialize(trakt)
      @trakt = trakt
      @token = trakt.token
      @headers = {
          'Content-Type' => 'application/json',
          'trakt-api-version' => '2',
          'trakt-api-key' => trakt.client_id,
      }
    end

    def get_access_token
      #TODO: Refresh token
      return @token if @token
      token_array = nil
      data = {'client_id': @trakt.client_id}
      r = JSON.load(Request.post( '/oauth/device/code',{:body => data}).body)
      device_code = r['device_code']
      user_code = r['user_code']
      expires_in = r['expires_in']
      interval = r['interval']
      puts "Please visit #{r['verification_url']} and authorize your app. Your user code is #{user_code} . Your code expires in #{expires_in.to_i / 60.0} minutes."
      data['code'] = device_code
      data['client_secret'] = @trakt.client_secret
      end_time = Time.now + expires_in.to_i.seconds
      print 'Waiting...'
      while Time.now < end_time
        sleep(interval)
        polling_request = Request.post('/oauth/device/token', {:body => data})
        case polling_request.code
          when 200
            token_array = JSON.load(polling_request.body)
            break
          when 400
            print '....'
          else
            puts "Error, received status code #{polling_request.code}"
            break
        end
      end
      if token_array
        @token = token_array
        return token_array
      end
      nil
    end

    def require_settings(required)
      required.each do |setting|
        raise "Required setting #{setting} is missing." unless @trakt.send(setting)
      end
    end

    def prepare_connection
      access_token = get_access_token['access_token'] rescue access_token = nil
      @headers.merge!({'Authorization' => "Bearer #{access_token}"}) if access_token
    end

    def post(path,body={})
      path << '/' unless path[-1] == '/'
      path = '/' + path unless path[0] == '/'
      prepare_connection
      result = Request.post(path, {:body => body.to_json, :headers => @headers})
      parse(result)
    end

    def parse(result)
      parsed =  JSON.parse result.body
      if parsed.kind_of? Hash and parsed['status'] and parsed['status'] == 'failure'
        raise Error.new(parsed['error'])
      end
      return parsed
    end

    def clean_query(query)
      query.gsub(/[()]/,'').
        gsub(' ','+').
        gsub('&','and').
        gsub('!','').
        chomp
    end

    def get(path,query)
      prepare_connection
      full_path = File.join(path, query)
      result = Request.get(full_path, {:headers => @headers})
      parse(result)
    end

    def get_with_args(path,*args)
      prepare_connection
      require_settings %w|account_id|
      arg_path = *args.compact.map { |t| t.to_s}
      get(path, File.join(arg_path))
    end

    private :get_with_args, :get, :post, :parse, :clean_query, :require
  end
end
