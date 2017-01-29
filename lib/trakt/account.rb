module Trakt
  class Account
    include Connection
    def access_token
      get_access_token
    end
    def settings
      require_settings %w|client_id client_secret account_id|
      post 'account/settings/'
    end
    def test
      require_settings %w|client_id client_secret account_id|
      post 'account/test/'
    end
  end
end
