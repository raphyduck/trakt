module Trakt
  module Connection
    def initialize(trakt)
      @trakt = trakt
      @headers = {
          'Content-Type' => 'application/json',
          'trakt-api-version' => '2',
          'trakt-api-key' => trakt.client_id,
      }
      @speaker = trakt.speaker
    end

    def get_access_token
      return @trakt.token if @trakt.token && Time.now < Time.at(@trakt.token['created_at'].to_i + @trakt.token['expires_in'].to_i)
      token_array = nil
      data = {client_id: @trakt.client_id}
      if @trakt.token.nil? || @trakt.token['refresh_token'].nil?
        r = JSON.load(Request.post('/oauth/device/code', {:body => JSON.dump(data)}).body)
        device_code = r['device_code']
        user_code = r['user_code']
        expires_in = r['expires_in']
        interval = r['interval']
        @speaker.speak_up "Please visit #{r['verification_url']} and authorize your app. Your user code is #{user_code} . Your code expires in #{expires_in.to_i / 60.0} minutes."
        data[:code] = device_code
        end_time = Time.now + expires_in.to_i.seconds
        print 'Waiting...'
        while Time.now < end_time
          sleep(interval)
          success, token_array = request_token('/oauth/device/token', data)
          break if success < 0 || token_array
          print '.'
        end
      else
        data[:refresh_token] = @trakt.token['refresh_token']
        data[:redirect_uri] = "urn:ietf:wg:oauth:2.0:oob"
        data[:grant_type] = "refresh_token"
        _, token_array = request_token('/oauth/token', data)
      end
      @trakt.token = token_array if token_array
      token_array
    end

    def request_token(url, data)
      data[:client_secret] = @trakt.client_secret unless data[:client_secret]
      success, token_array = 1, nil
      polling_request = Request.post(url, {:body => JSON.dump(data)})
      case polling_request.code
      when 200
        token_array = JSON.load(polling_request.body)
        token_array['expires_in'] = Time.now + token['expires_in'].to_i.seconds
      when 400
        success = 0
      else
        @speaker.speak_up "Error, received status code #{polling_request.code}"
        success = -1
      end
      return success, token_array
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

    def post(path, body = {})
      prepare_connection
      result = Request.post(clean_path(path), {:body => body.to_json, :headers => @headers})
      parse(result)
    end

    def parse(result)
      parsed = JSON.parse result.body
      if parsed.kind_of? Hash and parsed['status'] and parsed['status'] == 'failure'
        raise Error.new(parsed['error'])
      end
      return parsed
    end

    def clean_query(query)
      query.gsub(/[()]/, '').
          gsub(' ', '+').
          gsub('&', 'and').
          gsub('!', '').
          chomp
    end

    def clean_path(path)
      path << '/' unless path[-1] == '/' || path.include?('?')
      path = '/' + path unless path[0] == '/'
      path
    end

    def get(path, query, c_headers = {})
      prepare_connection
      full_path = File.join(path, query)
      result = Request.get(clean_path(full_path), {:headers => @headers.merge(c_headers)})
      parse(result)
    rescue => e
      {'error' => e.to_s}
    end

    def get_with_args(path, *args)
      prepare_connection
      require_settings %w|account_id|
      arg_path = *args.compact.map {|t| t.to_s}
      get(clean_path(path), File.join(arg_path))
    end

    private :get_with_args, :get, :post, :parse, :clean_query, :require
  end
end
