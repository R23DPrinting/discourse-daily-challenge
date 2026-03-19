# frozen_string_literal: true

module Jobs
  class DailyChallengeWeeklyPost < ::Jobs::Scheduled
    every 1.hour

    def execute(_args)
      return unless SiteSetting.daily_challenge_enabled

      DailyChallenge.active.includes(:topic).find_each do |challenge|
        next unless challenge.weekly_post_enabled
        next unless challenge.active?

        tz = ActiveSupport::TimeZone[challenge.challenge_timezone] || Time.zone
        now = Time.now.in_time_zone(tz)
        next unless now.wday == challenge.weekly_post_day
        next unless now.hour == challenge.weekly_post_hour

        DiscourseDailyChallenge::LeaderboardPoster.post_weekly_update(challenge)
      rescue StandardError => e
        Rails.logger.error(
          "DailyChallengeWeeklyPost error for challenge #{challenge.id}: #{e.message}\n#{e.backtrace.first(5).join("\n")}",
        )
      end
    end
  end
end
