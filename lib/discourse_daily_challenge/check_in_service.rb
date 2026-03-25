# frozen_string_literal: true

module DiscourseDailyChallenge
  class CheckInService
    IMAGE_EXTENSIONS = %w[jpg jpeg png gif webp heic avif].freeze

    def self.process(post)
      return if post.topic_id.nil?

      challenge = DailyChallenge.find_by(topic_id: post.topic_id)
      return unless challenge&.active?

      user = post.user
      return unless user

      return unless has_hashtag?(post, challenge.hashtag) || has_image?(post)

      user_date = user_local_date(user)

      if challenge.check_in_interval == "weekly"
        week_start_date, week_end_date = current_week_window(challenge)
        return if DailyCheckIn.exists?(
          challenge_id: challenge.id,
          user_id: user.id,
          check_in_date: week_start_date..week_end_date,
        )
      else
        return if DailyCheckIn.exists?(
          challenge_id: challenge.id,
          user_id: user.id,
          check_in_date: user_date,
        )
      end

      DailyCheckIn.create!(
        challenge_id: challenge.id,
        user_id: user.id,
        check_in_date: user_date,
        post_id: post.id,
        admin_added: false,
      )
    rescue StandardError => e
      Rails.logger.error("DailyChallenge check-in error for post #{post.id}: #{e.message}")
    end

    def self.has_hashtag?(post, hashtag)
      return false if hashtag.blank?
      post.raw.to_s.match?(/(?:^|\s)##{Regexp.escape(hashtag)}(?:\b|$)/i)
    end

    def self.has_image?(post)
      post.uploads.any? { |u| IMAGE_EXTENSIONS.include?(u.extension.to_s.downcase) }
    end

    def self.user_local_date(user)
      tz_name = user.user_option&.timezone.presence || "UTC"
      tz = ActiveSupport::TimeZone[tz_name] || Time.zone
      Time.now.in_time_zone(tz).to_date
    end

    def self.current_week_window(challenge)
      tz = ActiveSupport::TimeZone[challenge.challenge_timezone] || Time.zone
      today = Time.now.in_time_zone(tz).to_date
      wday = DiscourseDailyChallenge::ChallengeUtils.week_start_wday(challenge)
      week_start = DiscourseDailyChallenge::ChallengeUtils.week_start_for_date(today, wday)
      [week_start, week_start + 6]
    end
  end
end
