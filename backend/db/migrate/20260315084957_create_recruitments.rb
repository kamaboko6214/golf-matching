class CreateRecruitments < ActiveRecord::Migration[7.1]
  def change
    create_table :recruitments do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.date :play_date
      t.string :course_name
      t.string :prefecture
      t.integer :needed_players
      t.string :status, default: 'open'

      t.timestamps
    end
  end
end