# frozen_string_literal: true

module DiscourseDailyChallenge
  module ChallengeUtils
    # Returns the Ruby Date#wday value (0=Sun, 1=Mon … 6=Sat) for the
    # configured week_start of a challenge.
    def self.week_start_wday(challenge)
      case challenge.week_start
      when "sunday"
        0
      when "saturday"
        6
      else
        1 # monday (default)
      end
    end

    # Returns the date of the first day of the calendar week that contains
    # +date+, where the week boundary is defined by +week_start_wday+.
    def self.week_start_for_date(date, week_start_wday)
      days_since_start = (date.wday - week_start_wday) % 7
      date - days_since_start
    end
  end
end
