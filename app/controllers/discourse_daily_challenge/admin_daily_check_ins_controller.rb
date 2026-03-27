# frozen_string_literal: true

class DiscourseDailyChallenge::AdminDailyCheckInsController < Admin::AdminController
  requires_plugin DiscourseDailyChallenge::PLUGIN_NAME

  skip_before_action :ensure_admin
  before_action :ensure_challenge_manager
  before_action :check_mod_access
  before_action :find_challenge

  def index
    check_ins =
      DailyCheckIn
        .where(challenge_id: @challenge.id)
        .includes(:user)
        .order(check_in_date: :desc)
    render_serialized(check_ins, DailyCheckInSerializer, root: "check_ins")
  end

  def create
    target_user = User.find_by(id: params[:user_id]) || User.find_by(username: params[:username])
    raise Discourse::NotFound unless target_user

    date =
      begin
        Date.parse(params[:check_in_date].to_s)
      rescue ArgumentError
        raise Discourse::InvalidParameters.new(:check_in_date)
      end

    if @challenge.check_in_interval == "weekly"
      wday = DiscourseDailyChallenge::ChallengeUtils.week_start_wday(@challenge)
      week_start = DiscourseDailyChallenge::ChallengeUtils.week_start_for_date(date, wday)
      if DailyCheckIn.exists?(
           challenge_id: @challenge.id,
           user_id: target_user.id,
           check_in_date: week_start..(week_start + 6),
         )
        return render_json_error(I18n.t("daily_challenge.check_in.already_exists_this_week"))
      end
    elsif DailyCheckIn.exists?(
            challenge_id: @challenge.id,
            user_id: target_user.id,
            check_in_date: date,
          )
      return render_json_error(I18n.t("daily_challenge.check_in.already_exists"))
    end

    check_in =
      DailyCheckIn.create!(
        challenge_id: @challenge.id,
        user_id: target_user.id,
        check_in_date: date,
        admin_added: true,
      )

    render_serialized(check_in, DailyCheckInSerializer, root: "check_in")
  end

  def destroy
    check_in = DailyCheckIn.find_by(id: params[:id], challenge_id: @challenge.id)
    raise Discourse::NotFound unless check_in

    check_in.destroy
    render json: success_json
  end

  private

  def ensure_challenge_manager
    return if current_user&.admin?
    return if current_user&.moderator?
    return if SiteSetting.daily_challenge_category_mod_access_enabled && category_mod?(current_user)
    raise Discourse::InvalidAccess
  end

  def check_mod_access
    return if current_user.admin?
    return if SiteSetting.daily_challenge_mod_access_enabled
    return if category_mod?(current_user)

    render json: { error: I18n.t("daily_challenge.errors.access_denied") }, status: :forbidden
  end

  def find_challenge
    @challenge = DailyChallenge.find_by(id: params[:challenge_id])
    raise Discourse::NotFound unless @challenge

    unless current_user.admin? || current_user.moderator? ||
             (
               @challenge.category_id &&
                 category_mod_for_category?(current_user, @challenge.category_id)
             )
      render json: { error: I18n.t("daily_challenge.errors.access_denied") },
             status: :forbidden
    end
  end

  def category_mod?(user)
    ::CategoryModerationGroup.joins(group: :group_users).where(
      group_users: {
        user_id: user.id,
      },
    ).exists?
  end

  def category_mod_for_category?(user, category_id)
    ::CategoryModerationGroup.joins(group: :group_users).where(
      group_users: {
        user_id: user.id,
      },
      category_id: category_id,
    ).exists?
  end
end
