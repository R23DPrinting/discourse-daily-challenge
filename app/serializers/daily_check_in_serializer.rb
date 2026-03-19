# frozen_string_literal: true

class DailyCheckInSerializer < ApplicationSerializer
  attributes :id,
             :challenge_id,
             :user_id,
             :check_in_date,
             :post_id,
             :admin_added,
             :username,
             :avatar_template

  def username
    object.user&.username
  end

  def avatar_template
    object.user&.avatar_template
  end
end
