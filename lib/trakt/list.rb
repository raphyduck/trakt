module Trakt
  class List
    include Connection
    # TODO options should be the various options at some point
    attr_accessor :slug, :add_info

    def add_item(name, data, type)
      add_items(name, [data], type)
    end
    def add_items(list, data, type)
      post("/users/#{@trakt.account_id}/lists/#{list}/items/type", type => data)
    end

    def create_list(data)
      post("/users/#{@trakt.account_id}/lists", data)
    end

    def collection(type, extra = '')
     get("users/#{@trakt.account_id}/", "collection/#{type}#{extra}")
    end

    def get_history(type = '', item = '')
      get("users/#{@trakt.account_id}/", "history/#{type}/#{item}")
    end

    def get_user_list(name)
      get("users/#{@trakt.account_id}/lists/", name)
    end

    def get_user_lists
      get("/users/#{@trakt.account_id}/", "lists")
    end

    def get_watched(type, extra = '')
      get("/users/#{@trakt.account_id}/", "watched/#{type}#{extra}")
    end

    def item_delete(data)
      items_delete([data])
    end

    def items_delete(data)
      post("lists/items/delete/", 'slug' => slug, 'items' => data)
    end

    def delete
      post "lists/delete/", 'slug' => slug
    end

    def list(name = 'watchlist', type = '')
      get("users/#{@trakt.account_id}/lists/", name + '/items/' + type)
    end

    def watchlist(type = 'movies')
      get("users/#{@trakt.account_id}/watchlist/", type)
    end
  end
end
