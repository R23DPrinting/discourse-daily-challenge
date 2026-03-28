# frozen_string_literal: true

module Jobs
  class DiscourseDailyChallengeSendReminders < ::Jobs::Scheduled
    every 1.day

    def execute(_args)
      return unless SiteSetting.daily_challenge_enabled

      bot = DiscourseDailyChallenge.bot_user
      return unless bot

      DailyChallenge.active.select(&:active?).each do |challenge|
        next unless challenge.reminder_dms_enabled

        if challenge.check_in_interval == "weekly"
          send_weekly_reminders(bot, challenge)
        else
          send_daily_reminders(bot, challenge)
        end
      end
    end

    private

    def send_daily_reminders(bot, challenge)
      tz = ActiveSupport::TimeZone[challenge.challenge_timezone] || Time.zone
      today = Time.now.in_time_zone(tz).to_date
      yesterday = today - 1

      participant_ids =
        DailyCheckIn.where(challenge_id: challenge.id).distinct.pluck(:user_id)
      return if participant_ids.empty?

      checked_in_recently =
        DailyCheckIn
          .where(
            challenge_id: challenge.id,
            user_id: participant_ids,
            check_in_date: yesterday..today,
          )
          .distinct
          .pluck(:user_id)

      (participant_ids - checked_in_recently).each do |user_id|
        send_reminder_dm(bot, challenge, user_id)
      end
    end

    def send_weekly_reminders(bot, challenge)
      tz = ActiveSupport::TimeZone[challenge.challenge_timezone] || Time.zone
      today = Time.now.in_time_zone(tz).to_date
      wday = DiscourseDailyChallenge::ChallengeUtils.week_start_wday(challenge)
      week_start = DiscourseDailyChallenge::ChallengeUtils.week_start_for_date(today, wday)

      # Only send on the last day of the challenge week
      return unless (today - week_start) == 6

      participant_ids =
        DailyCheckIn.where(challenge_id: challenge.id).distinct.pluck(:user_id)
      return if participant_ids.empty?

      checked_in_this_week =
        DailyCheckIn
          .where(
            challenge_id: challenge.id,
            user_id: participant_ids,
            check_in_date: week_start..(week_start + 6),
          )
          .distinct
          .pluck(:user_id)

      (participant_ids - checked_in_this_week).each do |user_id|
        send_reminder_dm(bot, challenge, user_id)
      end
    end

    def send_reminder_dm(bot, challenge, user_id)
      redis_key = "daily_challenge:reminder_dm:#{challenge.id}:#{user_id}:#{Date.today}"
      return if Discourse.redis.get(redis_key)

      user = User.find_by(id: user_id)
      return unless user

      challenge_name = challenge.topic&.title || "##{challenge.hashtag}"
      topic_link =
        if challenge.topic
          "[**#{challenge.topic.title}**](#{Discourse.base_url}/t/#{challenge.topic.slug}/#{challenge.topic.id})"
        else
          "**##{challenge.hashtag}**"
        end

      check_in_count = DailyCheckIn.where(challenge_id: challenge.id, user_id: user_id).count
      checkin_count_text = I18n.t("daily_challenge.bot.checkin_count", count: check_in_count)

      PostCreator.create!(
        bot,
        title: I18n.t("daily_challenge.bot.reminder_dm_title", challenge_name: challenge_name),
        raw: I18n.t(
          "daily_challenge.bot.reminder_dm_body",
          topic_link: topic_link,
          checkin_count: checkin_count_text,
          needed: challenge.check_ins_needed,
        ),
        archetype: Archetype.private_message,
        target_usernames: [user.username],
        skip_validations: true,
      )

      Discourse.redis.setex(redis_key, 25.hours.to_i, "1")
    rescue StandardError => e
      Rails.logger.error(
        "DailyChallenge reminder DM error for user #{user_id}, challenge #{challenge.id}: #{e.message}",
      )
    end
  end
end
