module Trakt
  class Calendar
    include Connection

    ROUTES = {
      my_shows: %w[my shows],
      my_new_shows: ['my', 'shows/new'],
      my_show_premieres: ['my', 'shows/premieres'],
      my_show_seasons: ['my', 'shows/seasons'],
      my_movies: %w[my movies],
      my_new_movies: ['my', 'movies/new'],
      all_shows: %w[all shows],
      all_new_shows: ['all', 'shows/new'],
      all_show_premieres: ['all', 'shows/premieres'],
      all_show_seasons: ['all', 'shows/seasons'],
      all_movies: %w[all movies],
      all_new_movies: ['all', 'movies/new'],
    }.freeze

    ROUTES.each do |method_name, (scope, segment)|
      define_method(method_name) do |start_date = nil, days = nil|
        calendar(scope, segment, start_date, days)
      end
    end

    private

    def calendar(scope, segment, start_date, days)
      path = ['/calendars', scope, segment].join('/')
      get_with_args(path, *[start_date, days].compact)
    end
  end
end
