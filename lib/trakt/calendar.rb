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
      calendar_get_with_args(path, scope, *[start_date, days].compact)
    end

    def calendar_get_with_args(path, scope, *args)
      require_settings %w|account_id| if scope == 'my'
      prepare_connection
      arg_path = args.compact.map { |t| t.to_s }
      get(clean_path(path), File.join(arg_path))
    end
  end
end
