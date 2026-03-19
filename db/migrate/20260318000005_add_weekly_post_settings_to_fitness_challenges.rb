# frozen_string_literal: true

class AddWeeklyPostSettingsToFitnessChallenges < ActiveRecord::Migration[7.0]
  def change
    add_column :fitness_challenges, :weekly_post_enabled, :boolean, default: true, null: false
    add_column :fitness_challenges, :weekly_post_day, :integer, default: 1, null: false
    add_column :fitness_challenges, :weekly_post_hour, :integer, default: 9, null: false
  end
end
