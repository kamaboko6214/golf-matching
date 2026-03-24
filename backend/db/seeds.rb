# テストユーザー作成
test_user = User.find_or_create_by!(email: "test@golf.com") do |u|
  u.password = "password123"
end

test_user2 = User.find_or_create_by!(email: "test2@golf.com") do |u|
  u.password = "password123"
end

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