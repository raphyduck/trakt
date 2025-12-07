require File.dirname(__FILE__) + '/spec_helper'

RSpec.describe Trakt::Calendar do
  let(:details) { get_account_details }
  let(:trakt) do
    Trakt::Trakt.new(
      account_id: details['account_id'],
      client_id: details['client_id'],
      client_secret: details['client_secret'],
      token: details['token']
    )
  end

  subject(:calendar) { described_class.new(trakt) }

  let(:start_date) { '2024-01-01' }
  let(:days) { 3 }
  let(:base_uri) { 'https://api.trakt.tv' }
  let(:cassette_interactions) do
    Hash.new do |memo, name|
      path = File.join(__dir__, "fixtures/vcr_cassettes/#{name}.yml")
      memo[name] = YAML.safe_load(File.read(path)).fetch('http_interactions')
    end
  end

  shared_examples 'calendar endpoint' do |method_name, cassette_name, expectation|
    it "fetches #{method_name} calendar entries" do
      interactions = cassette_interactions[cassette_name]

      allow(Trakt::Request).to receive(:get) do |path, options|
        uri = base_uri + path
        interaction = interactions.find { |entry| entry.dig('request', 'uri') == uri }
        raise "No cassette entry for #{uri}" unless interaction

        response_body = interaction.dig('response', 'body', 'string')
        Struct.new(:body).new(response_body)
      end

      response = VCR.use_cassette(cassette_name) do
        calendar.public_send(method_name, start_date, days)
      end

      expect(response).to be_an(Array)
      expect(response.first).to include(expectation.fetch(:key))
      if expectation[:title_path]
        target = expectation[:title_path].reduce(response.first) { |acc, key| acc[key] }
        expect(target).to eq(expectation.fetch(:title))
      end

      expect(Trakt::Request).to have_received(:get).with(
        expectation.fetch(:path),
        hash_including(headers: hash_including(
          'trakt-api-key' => details['client_id'],
          'Authorization' => "Bearer #{details.dig('token', 'access_token')}"
        ))
      )
    end
  end

  describe 'my calendar' do
    include_examples 'calendar endpoint', :my_shows, 'calendar/my',
      key: 'show', title_path: %w[show title], title: 'My Returning Show',
      path: '/calendars/my/shows/2024-01-01/3/'
    include_examples 'calendar endpoint', :my_new_shows, 'calendar/my',
      key: 'show', title_path: %w[show title], title: 'My New Show',
      path: '/calendars/my/shows/new/2024-01-01/3/'
    include_examples 'calendar endpoint', :my_show_premieres, 'calendar/my',
      key: 'show', title_path: %w[show title], title: 'My Premiere Show',
      path: '/calendars/my/shows/premieres/2024-01-01/3/'
    include_examples 'calendar endpoint', :my_show_seasons, 'calendar/my',
      key: 'season', title_path: %w[show title], title: 'Seasonal My Show',
      path: '/calendars/my/shows/seasons/2024-01-01/3/'
    include_examples 'calendar endpoint', :my_movies, 'calendar/my',
      key: 'movie', title_path: %w[movie title], title: 'My Calendar Movie',
      path: '/calendars/my/movies/2024-01-01/3/'
    include_examples 'calendar endpoint', :my_new_movies, 'calendar/my',
      key: 'movie', title_path: %w[movie title], title: 'My New Calendar Movie',
      path: '/calendars/my/movies/new/2024-01-01/3/'
  end

  describe 'all calendars' do
    include_examples 'calendar endpoint', :all_shows, 'calendar/all',
      key: 'show', title_path: %w[show title], title: 'All Returning Show',
      path: '/calendars/all/shows/2024-01-01/3/'
    include_examples 'calendar endpoint', :all_new_shows, 'calendar/all',
      key: 'show', title_path: %w[show title], title: 'All New Show',
      path: '/calendars/all/shows/new/2024-01-01/3/'
    include_examples 'calendar endpoint', :all_show_premieres, 'calendar/all',
      key: 'show', title_path: %w[show title], title: 'All Premiere Show',
      path: '/calendars/all/shows/premieres/2024-01-01/3/'
    include_examples 'calendar endpoint', :all_show_seasons, 'calendar/all',
      key: 'season', title_path: %w[show title], title: 'Seasonal All Show',
      path: '/calendars/all/shows/seasons/2024-01-01/3/'
    include_examples 'calendar endpoint', :all_movies, 'calendar/all',
      key: 'movie', title_path: %w[movie title], title: 'All Calendar Movie',
      path: '/calendars/all/movies/2024-01-01/3/'
    include_examples 'calendar endpoint', :all_new_movies, 'calendar/all',
      key: 'movie', title_path: %w[movie title], title: 'All New Calendar Movie',
      path: '/calendars/all/movies/new/2024-01-01/3/'
  end
end
