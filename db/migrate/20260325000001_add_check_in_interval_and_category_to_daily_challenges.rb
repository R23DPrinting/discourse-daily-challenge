# frozen_string_literal: true

class AddCheckInIntervalAndCategoryToDailyChallenges < ActiveRecord::Migration[7.0]
  def up
    table = table_exists?(:fitness_challenges) ? :fitness_challenges : :daily_challenges
    return unless table_exists?(table)

    add_column table, :check_in_interval, :string, default: "daily", null: false unless column_exists?(table, :check_in_interval)
    add_column table, :week_start, :string, null: true unless column_exists?(table, :week_start)
    add_column table, :category_id, :integer, null: true unless column_exists?(table, :category_id)
  end

  def down
    table = table_exists?(:fitness_challenges) ? :fitness_challenges : :daily_challenges
    return unless table_exists?(table)

    remove_column table, :check_in_interval if column_exists?(table, :check_in_interval)
    remove_column table, :week_start if column_exists?(table, :week_start)
    remove_column table, :category_id if column_exists?(table, :category_id)
  end
end
