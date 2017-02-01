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

    def add_or_remove_item(action, list_type, type, list, list_name = '')
      validate_item(type, list)
      require_settings %w|client_id client_secret account_id|
      options = list.is_a?(Array) ? {type => list} : list
      case list_type
        when 'collection'
          post("/sync/collection#{'/remove' if action == 'remove'}", options)
        else
          post("/users/#{@trakt.account_id}/lists/#{list_name}/items/#{'/remove' if action == 'remove'}", options)
      end
    end

    def validate_item(type, list)
      raise "Invalid type #{type}" unless ['movies', 'shows', 'episodes', ''].include?(type)
      raise "Invalid type of list. 'list' must be an Array" unless list.is_a?(Array) || list.is_a?(Hash)
    end
  end
end
