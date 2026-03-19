# frozen_string_literal: true

class CreateFitnessChallenges < ActiveRecord::Migration[7.0]
  def change
    create_table :fitness_challenges do |t|
      t.integer :topic_id, null: false
      t.string :hashtag, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.integer :check_ins_needed, null: false, default: 20
      t.text :description

      t.timestamps
    end

    add_index :fitness_challenges, :topic_id, unique: true
  end
end
