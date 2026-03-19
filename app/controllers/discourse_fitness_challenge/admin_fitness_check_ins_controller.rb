# frozen_string_literal: true

class DiscourseFitnessChallenge::AdminFitnessCheckInsController < Admin::AdminController
  requires_plugin DiscourseFitnessChallenge::PLUGIN_NAME

  before_action :find_challenge

  def index
    check_ins =
      FitnessCheckIn
        .where(challenge_id: @challenge.id)
        .includes(:user)
        .order(check_in_date: :desc)
    render_serialized(check_ins, FitnessCheckInSerializer, root: "check_ins")
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

    if FitnessCheckIn.exists?(
         challenge_id: @challenge.id,
         user_id: target_user.id,
         check_in_date: date,
       )
      return render_json_error(I18n.t("fitness_challenge.check_in.already_exists"))
    end

    check_in =
      FitnessCheckIn.create!(
        challenge_id: @challenge.id,
        user_id: target_user.id,
        check_in_date: date,
        admin_added: true,
      )

    render_serialized(check_in, FitnessCheckInSerializer, root: "check_in")
  end

  def destroy
    check_in = FitnessCheckIn.find_by(id: params[:id], challenge_id: @challenge.id)
    raise Discourse::NotFound unless check_in

    check_in.destroy
    render json: success_json
  end

  private

  def find_challenge
    @challenge = FitnessChallenge.find_by(id: params[:challenge_id])
    raise Discourse::NotFound unless @challenge
  end
end
