module Trakt
  class Calendar
    include Connection
    def premieres(*args)
      calendar_get('/calendar/premieres.json/', *args)
    end
    def shows(*args)
      calendar_get('/calendar/shows.json/', *args)
    end

    private

    def calendar_get(path, *args)
      prepare_connection
      require_settings %w|account_id| if calendar_requires_auth?(args)
      arg_path = args.compact.map { |t| t.to_s }
      get(clean_path(path), File.join(arg_path))
    end

    def calendar_requires_auth?(args)
      args.first.to_s == 'my'
    end
  end
end
