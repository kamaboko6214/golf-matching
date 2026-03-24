# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
test_user = User.find_or_create_by!(email: "test@golf.com") do |u|
  u.password = "password123"
end

test_user.profile || test_user.create_profile!(
  name: "テストユーザー",
  handicap: 18,
  prefecture: "東京都",
  bio: "ゴルフ歴5年。週末プレイヤーです！"
)

test_user2 = User.find_or_create_by!(email: "test2@golf.com") do |u|
  u.password = "password123"
end

test_user2.profile || test_user2.create_profile!(
  name: "山田 太郎",
  handicap: 10,
  prefecture: "大阪府",
  bio: "シングルプレイヤーを目指して練習中です！"
)

# テスト募集データ
Recruitment.find_or_create_by!(title: "週末ゴルフ一緒にどうですか", user: test_user) do |r|
  r.description = "初心者歓迎！楽しくラウンドしましょう"
  r.play_date = Date.today + 7
  r.course_name = "東京ゴルフ倶楽部"
  r.prefecture = "東京都"
  r.needed_players = 3
  r.status = "open"
end

puts "シードデータ作成完了！"