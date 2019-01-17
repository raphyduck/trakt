module Trakt
  class Movie
    include Connection
    def aliases(movie_id)
      get_with_args("/movies/#{movie_id}/aliases")
    end
    def cancelcheckin
      post("/movie/cancelcheckin")
    end
    def cancelwatching
      post("/movie/cancelwatching")
    end
    def checkin(options = {})
      post("/movie/checkin", options)
    end
    def scrobble(options = {})
      post("/movie/scrobble", options)
    end
    def seen(options = {})
      post("/movie/seen", options)
    end
    def library(options = {})
      post("/movie/library", options)
    end
    def related(*args)
      get_with_args('/search/related.json/', *args)
    end
    def releases(movie_id, country, *args)
      get_with_args("/movies/#{movie_id}/releases/#{country}", *args)
    end
    def shouts(*args)
      get_with_args('/search/shouts.json/', *args)
    end
    def summary(movie_id, *args)
      get_with_args("/movies/#{movie_id}", *args)
    end
    def unlibrary(options = {})
      post("/movie/unlibrary", options)
    end
    def unseen(options = {})
      post("/movie/unseen", options)
    end
    def unwatchlist(options = {})
      post("/movie/unwatchlist", options)
    end
    def watching(options = {})
      post("/movie/watching", options)
    end
    def watchingnow(*args)
      get_with_args('/search/watchingnow.json/', *args)
    end
    def watchlist(options = {})
      post("/movie/watchlist", options)
    end
  end
end
