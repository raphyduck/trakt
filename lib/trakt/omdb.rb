module Trakt
  class Omdb
    include HTTParty

    base_uri 'https://www.omdbapi.com'

    def initialize(api_key)
      @api_key = api_key
      @cache = {}
    end

    def ratings_for(imdb_id)
      @cache[imdb_id] ||= begin
        response = self.class.get('/', query: { i: imdb_id, apikey: @api_key })
        data = response.parsed_response
        next unless data.is_a?(Hash) && data['Response'] == 'True'

        rating = normalize_rating(data['imdbRating'])
        votes = normalize_votes(data['imdbVotes'])
        rating || votes ? { 'imdb_rating' => rating, 'imdb_votes' => votes } : nil
      rescue StandardError
        nil
      end
    end

    private

    def normalize_rating(rating)
      Float(rating)
    rescue StandardError
      nil
    end

    def normalize_votes(votes)
      Integer(votes.to_s.delete(','))
    rescue StandardError
      nil
    end
  end
end
