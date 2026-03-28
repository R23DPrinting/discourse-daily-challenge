# frozen_string_literal: true

module Jobs
  class DiscourseDailyChallengeSendCheckinDm < ::Jobs::Base
    def execute(args)
      return unless SiteSetting.daily_challenge_enabled

      bot = DiscourseDailyChallenge.bot_user
      return unless bot

      user = User.find_by(id: args[:user_id])
      return unless user

      challenge = DailyChallenge.find_by(id: args[:challenge_id])
      return unless challenge

      streak = DiscourseDailyChallenge::ChallengeUtils.user_streak(challenge, user.id)
      streak_text =
        if challenge.check_in_interval == "weekly"
          I18n.t("daily_challenge.bot.streak_week", count: streak)
        else
          I18n.t("daily_challenge.bot.streak_day", count: streak)
        end

      topic = challenge.topic
      challenge_name = topic&.title || "##{challenge.hashtag}"
      topic_link =
        if topic
          "[**#{challenge_name}**](#{Discourse.base_url}/t/#{topic.slug}/#{topic.id})"
        else
          "**#{challenge_name}**"
        end

      PostCreator.create!(
        bot,
        title: I18n.t("daily_challenge.bot.checkin_dm_title"),
        raw: I18n.t(
          "daily_challenge.bot.checkin_dm_body",
          topic_link: topic_link,
          streak_text: streak_text,
        ),
        archetype: Archetype.private_message,
        target_usernames: [user.username],
        skip_validations: true,
      )
    rescue StandardError => e
      Rails.logger.error(
        "DailyChallenge checkin DM error for user #{args[:user_id]}, challenge #{args[:challenge_id]}: #{e.message}",
      )
    end
  end
end
