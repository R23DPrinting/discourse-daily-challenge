# frozen_string_literal: true

class DiscourseFitnessChallenge::AdminFitnessDashboardController < Admin::AdminController
  requires_plugin DiscourseFitnessChallenge::PLUGIN_NAME

  def show
    challenge = FitnessChallenge.active.includes(:topic, check_ins: :user).first

    if challenge.nil?
      render json: { challenge: nil, leaderboard: [], stats: {} }
      return
    end

    check_ins_by_user = challenge.check_ins.group_by(&:user_id)
    today = Date.current

    leaderboard =
      check_ins_by_user
        .filter_map do |user_id, check_ins|
          user = check_ins.first.user
          next unless user

          dates = check_ins.map { |ci| ci.check_in_date.to_date }.sort.uniq
          {
            user_id: user_id,
            username: user.username,
            name: user.name.presence || user.username,
            avatar_template: user.avatar_template,
            total_check_ins: dates.size,
            streak: calculate_streak(dates, today),
            completion_pct: completion_pct(dates.size, challenge.check_ins_needed),
            check_in_dates: dates.map(&:iso8601),
          }
        end
        .sort_by { |e| -e[:total_check_ins] }
        .each_with_index
        .map { |e, i| e.merge(rank: i + 1) }

    total = leaderboard.size
    avg_check_ins =
      total > 0 ? (leaderboard.sum { |e| e[:total_check_ins] }.to_f / total).round(1) : 0

    render json: {
             challenge: {
               id: challenge.id,
               hashtag: challenge.hashtag,
               check_ins_needed: challenge.check_ins_needed,
               start_date: challenge.start_date.iso8601,
               end_date: challenge.end_date.iso8601,
               elapsed_days: challenge.elapsed_days,
               total_days: (challenge.end_date - challenge.start_date).to_i,
               topic_url: challenge.topic&.relative_url,
               topic_title: challenge.topic&.title,
             },
             leaderboard: leaderboard,
             stats: {
               total_participants: total,
               avg_check_ins: avg_check_ins,
               progress_pct: challenge_progress_pct(challenge),
             },
           }
  end

  private

  def completion_pct(check_ins, needed)
    return 0 if needed <= 0
    ((check_ins.to_f / needed) * 100).round(1)
  end

  def challenge_progress_pct(challenge)
    total_days = (challenge.end_date - challenge.start_date).to_i
    return 0 if total_days <= 0
    ((challenge.elapsed_days.to_f / total_days) * 100).round(1)
  end

  # Count the longest run of consecutive days ending on today or yesterday.
  def calculate_streak(sorted_dates, today)
    return 0 if sorted_dates.empty?

    # Streak must touch today or yesterday, otherwise it's broken
    return 0 if sorted_dates.last < today - 1

    streak = 0
    expected = [sorted_dates.last, today].min

    sorted_dates.reverse_each do |date|
      break if date != expected

      streak += 1
      expected -= 1
    end

    streak
  end
end
