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
      items = get(clean_path(path), File.join(arg_path))
      return items unless omdb_client

      items.each do |item|
        target = omdb_target(item)
        next unless target && target['imdb_rating'].nil? && target['imdb_votes'].nil?

        rating = omdb_client.ratings_for(target.dig('ids', 'imdb'))
        next unless rating

        target.merge!(rating)
      end

      items
    end

    def omdb_client
      return unless @trakt.respond_to?(:omdb_api_key) && @trakt.omdb_api_key

      @omdb_client ||= Omdb.new(@trakt.omdb_api_key)
    end

    def omdb_target(item)
      [item['show'], item['movie'], item['episode'], item].find do |candidate|
        candidate.is_a?(Hash) && candidate.dig('ids', 'imdb')
      end
    end
  end
end
