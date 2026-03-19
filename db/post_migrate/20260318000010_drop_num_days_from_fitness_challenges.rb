# frozen_string_literal: true

class DropNumDaysFromFitnessChallenges < ActiveRecord::Migration[7.0]
  def up
    Migration::ColumnDropper.execute_drop(:fitness_challenges, [:num_days])
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
