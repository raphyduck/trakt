module Trakt
  class Friends
    include Connection
    def add(username)
      require_settings %w|client_id client_secret account_id|
      post "friends/#{__method__}/", 'friend' => username
    end
    def all
      require_settings %w|client_id client_secret account_id|
      post 'friends/all/'
    end
    def approve(username)
      require_settings %w|client_id client_secret account_id|
      post "friends/#{__method__}/", 'friend' => username
    end
    def delete(username)
      require_settings %w|client_id client_secret account_id|
      post "friends/#{__method__}/", 'friend' => username
    end
    def deny
      require_settings %w|client_id client_secret account_id|
      post "friends/#{__method__}/", 'friend' => username
    end
    def requests(username)
      require_settings %w|client_id client_secret account_id|
      post 'friends/requests/'
    end
  end
end
