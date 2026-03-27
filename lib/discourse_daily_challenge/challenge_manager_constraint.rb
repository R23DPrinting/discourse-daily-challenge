# frozen_string_literal: true

module DiscourseDailyChallenge
  class ChallengeManagerConstraint
    def matches?(request)
      user = CurrentUser.lookup_from_env(request.env)
      return false unless user
      return true if user.admin?
      return true if user.moderator?
      ::CategoryModerationGroup.joins(group: :group_users).where(group_users: { user_id: user.id }).exists?
    rescue Discourse::InvalidAccess, Discourse::ReadOnly
      false
    end
  end
end
