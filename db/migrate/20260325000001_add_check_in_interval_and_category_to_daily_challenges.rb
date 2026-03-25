# frozen_string_literal: true

class AddCheckInIntervalAndCategoryToDailyChallenges < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:daily_challenges, :check_in_interval)
      add_column :daily_challenges, :check_in_interval, :string, default: "daily", null: false
    end

    unless column_exists?(:daily_challenges, :week_start)
      add_column :daily_challenges, :week_start, :string, null: true
    end

    unless column_exists?(:daily_challenges, :category_id)
      add_column :daily_challenges, :category_id, :integer, null: true
    end
  end
end
