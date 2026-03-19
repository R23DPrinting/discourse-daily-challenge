# frozen_string_literal: true

class CreateFitnessCheckIns < ActiveRecord::Migration[7.0]
  def change
    create_table :fitness_check_ins do |t|
      t.integer :challenge_id, null: false
      t.integer :user_id, null: false
      t.date :check_in_date, null: false
      t.integer :post_id
      t.boolean :admin_added, null: false, default: false

      t.timestamps
    end

    add_index :fitness_check_ins, %i[challenge_id user_id check_in_date],
              unique: true,
              name: "idx_fitness_check_ins_unique_per_user_day"
    add_index :fitness_check_ins, :user_id
    add_index :fitness_check_ins, :post_id
  end
end
