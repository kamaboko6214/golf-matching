class RenameHandicapToAverageScoreInProfiles < ActiveRecord::Migration[7.1]
  def change
    rename_column :profiles, :handicap, :average_score
  end
end
