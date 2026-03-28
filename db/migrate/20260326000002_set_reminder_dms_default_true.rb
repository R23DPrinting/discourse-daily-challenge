# frozen_string_literal: true

class SetReminderDmsDefaultTrue < ActiveRecord::Migration[7.0]
  def up
    if table_exists?(:daily_challenges)
      execute "UPDATE daily_challenges SET reminder_dms_enabled = TRUE WHERE reminder_dms_enabled = FALSE"
    elsif table_exists?(:fitness_challenges)
      execute "UPDATE fitness_challenges SET reminder_dms_enabled = TRUE WHERE reminder_dms_enabled = FALSE"
    end
  end

  def down
    # Not reversible — original per-row values are not recoverable
    raise ActiveRecord::IrreversibleMigration
  end
end
