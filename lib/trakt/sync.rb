module Trakt
  class Sync
    include Connection

    def mark_watched(list, type)
      validate_item(type, list)
      require_settings %w|client_id client_secret account_id|
      options = {
          type => list
      }
      post('/sync/history', options)
    end

    def add_or_remove_item(action, list_name, type, list)
      validate_item(type, list)
      require_settings %w|client_id client_secret account_id|
      options = list.is_a?(Array) ? {type => list} : list
      case list_name
        when 'watchlist'
          u = '/sync/watchlist'
        when 'collection'
          u = '/sync/collection'
        else
          u = "/users/#{@trakt.account_id}/lists/#{list_name}/items"
      end
      post("#{u}#{'/remove' if action == 'remove'}", options)
    end

    def validate_item(type, list)
      raise "Invalid type #{type}" unless ['movies', 'shows', 'episodes', ''].include?(type)
      raise "Invalid type of list. 'list' must be an Array" unless list.is_a?(Array) || list.is_a?(Hash)
    end
  end
end
