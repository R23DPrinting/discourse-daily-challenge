# frozen_string_literal: true

class AddBadgeFieldsToFitnessChallenges < ActiveRecord::Migration[7.0]
  def change
    add_column :fitness_challenges, :award_badge, :boolean, default: true, null: false
    add_column :fitness_challenges, :badge_name, :string
    add_column :fitness_challenges, :badge_id, :integer
  end
end
