module Trakt
  class Sync
    include Connection
    def mark_watched(list, type)
      raise "Invalid type #{type}" unless ['movies', 'shows', 'episodes'].include?(type)
      raise "Invalid type of list. 'list' must be an Array" unless list.is_a?(Array)
      require_settings %w|client_id client_secret account_id|
      options = {
          type => list
      }
      post('/sync/history', options)
    end
  end
end
