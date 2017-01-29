module Trakt
  class Request
    include HTTParty
    base_uri 'https://api.trakt.tv'
  end
end