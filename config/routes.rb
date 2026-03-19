# frozen_string_literal: true

DiscourseFitnessChallenge::Engine.routes.draw do
  # no engine routes needed
end

Discourse::Application.routes.draw do
  scope "/admin/plugins/discourse-fitness-challenge",
        constraints: StaffConstraint.new do
    get "/challenges" =>
          "discourse_fitness_challenge/admin_fitness_challenges#index",
        as: :fitness_challenge_admin_challenges
    post "/challenges" =>
           "discourse_fitness_challenge/admin_fitness_challenges#create"
    get "/challenges/:id" =>
          "discourse_fitness_challenge/admin_fitness_challenges#show"
    put "/challenges/:id" =>
          "discourse_fitness_challenge/admin_fitness_challenges#update"
    delete "/challenges/:id" =>
             "discourse_fitness_challenge/admin_fitness_challenges#destroy"
    post "/challenges/:id/post_leaderboard" =>
           "discourse_fitness_challenge/admin_fitness_challenges#post_leaderboard"

    get "/challenges/:challenge_id/check_ins" =>
          "discourse_fitness_challenge/admin_fitness_check_ins#index"
    post "/challenges/:challenge_id/check_ins" =>
           "discourse_fitness_challenge/admin_fitness_check_ins#create"
    delete "/challenges/:challenge_id/check_ins/:id" =>
             "discourse_fitness_challenge/admin_fitness_check_ins#destroy"

    get "/dashboard" => "discourse_fitness_challenge/admin_fitness_dashboard#show"
  end
end
