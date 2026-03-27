# frozen_string_literal: true

class AddChallengeTimezoneToFitnessChallenges < ActiveRecord::Migration[7.0]
  def up
    if table_exists?(:fitness_challenges)
      add_column :fitness_challenges, :challenge_timezone, :string, null: false, default: "UTC" unless column_exists?(:fitness_challenges, :challenge_timezone)
    elsif table_exists?(:daily_challenges)
      add_column :daily_challenges, :challenge_timezone, :string, null: false, default: "UTC" unless column_exists?(:daily_challenges, :challenge_timezone)
    end
  end

  def down
    if table_exists?(:fitness_challenges)
      remove_column :fitness_challenges, :challenge_timezone if column_exists?(:fitness_challenges, :challenge_timezone)
    elsif table_exists?(:daily_challenges)
      remove_column :daily_challenges, :challenge_timezone if column_exists?(:daily_challenges, :challenge_timezone)
    end
  end
end
