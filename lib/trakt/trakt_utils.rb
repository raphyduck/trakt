module Trakt
  class TraktUtils
    def self.recursive_typify_keys(h, symbolize = 1)
      typify = symbolize.to_i > 0 ? 'to_sym' : 'to_s'
      case h
      when Hash
        Hash[
            h.map do |k, v|
              [k.respond_to?(typify) ? k.public_send(typify) : k, recursive_typify_keys(v, symbolize)]
            end
        ]
      when Enumerable
        h.map {|v| recursive_typify_keys(v, symbolize)}
      else
        h
      end
    end
  end
end