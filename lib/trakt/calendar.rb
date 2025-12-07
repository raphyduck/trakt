module Trakt
  class Calendar
    include Connection
    def premieres(*args)
      get_with_args('/calendars/all/shows/premieres', *args)
    end
    def shows(*args)
      get_with_args('/calendars/all/shows', *args)
    end
  end
end
