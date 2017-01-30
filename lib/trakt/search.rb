module Trakt
  class Search
    include Connection
    def movies(query)
      get('/search/movie/?query=',clean_query(query))
    end
    def shows(query)
      get('/search/show/?query=',clean_query(query))
    end
    def episode(query)
      get('/search/episode/?query=',clean_query(query))
    end
    def people(query)
      get('/search/person/?query=',clean_query(query))
    end
    def users(query)
      get('/search/list/?query=',clean_query(query))
    end
    def search_by_id(type, id)
      get("/search/#{type}/", id)
    end
  end
end
