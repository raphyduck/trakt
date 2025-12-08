$LOAD_PATH.unshift(File.dirname(__FILE__)) unless
    $LOAD_PATH.include?(File.dirname(__FILE__)) || $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))
require "trakt/version"
require "json"
require "httparty"
require "digest"
require "trakt/connection"
require "trakt/account"
require "trakt/list"
require "trakt/movie"
require "trakt/search"
require "trakt/activity"
require "trakt/calendar"
require "trakt/show"
require "trakt/friends"
require "trakt/movies"
require "trakt/genres"
require "trakt/request"
require "trakt/sync"
require 'trakt/trakt_utils'

module Trakt
  class Error < RuntimeError
    def initialize(message = nil, trace = nil)
      $stderr.puts("#{self.class}: #{message}")
      (trace || caller).take(5).each { |line| $stderr.puts("  #{line}") }
      super(message)
    end
  end
end
module Trakt
  def self.new(*a)
    Trakt.new(*a)
  end
  class Trakt
    attr_accessor :client_id, :client_secret, :account_id, :token
    def initialize(args={})
      @client_id = args[:client_id]
      @client_secret = args[:client_secret]
      @account_id = args[:account_id]
      @token = args[:token]
    end
    def access_token
      account.access_token
    end
    def account
      @account ||= Account.new self
    end
    def calendar
      @calendar ||= Calendar.new self
    end
    def friends
      @calendar ||= Calendar.new self
    end
    def search
      @search ||= Search.new self
    end
    def list
      @list ||= List.new self
    end
    def movie
      @movie ||= Movie.new self
    end
    def activity
      @activity ||= Activity.new self
    end
    def genres
      @genres ||= Genres.new self
    end
    def show
      @show ||= Show.new self
    end
    def sync
      @sync ||= Sync.new self
    end
  end
end
