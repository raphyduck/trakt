module Trakt
  class Genres
    include Connection
    def movies
      get "/genres/movies",''
    end
    def shows
      get "/genres/shows",''
    end
  end
end
