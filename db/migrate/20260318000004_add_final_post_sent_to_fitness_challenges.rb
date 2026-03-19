# frozen_string_literal: true

class AddFinalPostSentToFitnessChallenges < ActiveRecord::Migration[7.0]
  def change
    add_column :fitness_challenges, :final_post_sent, :boolean, default: false, null: false
  end
end
