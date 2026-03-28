# frozen_string_literal: true

class AddReminderDmsToDailyChallenges < ActiveRecord::Migration[7.0]
  def up
    if table_exists?(:fitness_challenges)
      add_column :fitness_challenges, :reminder_dms_enabled, :boolean, default: true, null: false unless column_exists?(:fitness_challenges, :reminder_dms_enabled)
    elsif table_exists?(:daily_challenges)
      add_column :daily_challenges, :reminder_dms_enabled, :boolean, default: true, null: false unless column_exists?(:daily_challenges, :reminder_dms_enabled)
    end
  end

  def down
    if table_exists?(:fitness_challenges)
      remove_column :fitness_challenges, :reminder_dms_enabled if column_exists?(:fitness_challenges, :reminder_dms_enabled)
    elsif table_exists?(:daily_challenges)
      remove_column :daily_challenges, :reminder_dms_enabled if column_exists?(:daily_challenges, :reminder_dms_enabled)
    end
  end
end
