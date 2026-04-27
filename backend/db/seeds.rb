# テストユーザー作成
users = [
  { email: "test@golf.com",     name: "山田 太郎",   average_score: 95  },
  { email: "test2@golf.com",    name: "佐藤 花子",   average_score: 110 },
  { email: "tanaka@golf.com",   name: "田中 健二",   average_score: 78  },
  { email: "suzuki@golf.com",   name: "鈴木 美咲",   average_score: 102 },
  { email: "ito@golf.com",      name: "伊藤 大輔",   average_score: 72  },  
  { email: "watanabe@golf.com", name: "渡辺 さくら", average_score: 130 },
  { email: "yamamoto@golf.com", name: "山本 浩二",   average_score: 88  },
]

created_users = users.map do |user|
  User.find_or_create_by!(email: user[:email]) do |u|
    u.password = "password123"
  end
end

test_user, test_user2, tanaka, suzuki, ito, watanabe, yamamoto = created_users

# 募集データ
recruitments = [
  {
    title: "週末ゴルフ一緒にどうですか",
    user: test_user,
    description: "初心者歓迎！楽しくラウンドしましょう😊",
    play_date: Date.today + 7,
    course_name: "東京ゴルフ倶楽部",
    prefecture: "東京都",
    needed_players: 3,
    status: "open",
  },
  {
    title: "平日ラウンド！スコア100前後の方募集",
    user: test_user2,
    description: "平日に有給取ってラウンド予定です。100前後で楽しくプレーできる方歓迎。カート付きのフラットなコースなので初心者でも安心です。",
    play_date: Date.today + 3,
    course_name: "千葉セントラルカントリークラブ",
    prefecture: "千葉県",
    needed_players: 2,
    status: "open",
  },
  {
    title: "早朝ハーフ！仕事前にサクッと回りたい方",
    user: tanaka,
    description: "6時スタートのハーフラウンドです。スコアより気持ちよくプレーすることを重視してます。経験者優遇ですがやる気のある方なら大歓迎！",
    play_date: Date.today + 2,
    course_name: "横浜カントリークラブ",
    prefecture: "神奈川県",
    needed_players: 1,
    status: "open",
  },
  {
    title: "女性同士でゴルフしませんか？",
    user: suzuki,
    description: "女性限定の募集です🌸 ゆっくりマイペースに楽しみましょう！スコアは気にしなくてOK。ランチも一緒にどうぞ。",
    play_date: Date.today + 14,
    course_name: "埼玉クラシックゴルフ倶楽部",
    prefecture: "埼玉県",
    needed_players: 2,
    status: "open",
  },
  {
    title: "競技志向の方！本気でラウンドしたい",
    user: ito,
    description: "ハンデ15以下の方向け。スコアをしっかり競いたい方募集です。コースマネジメントの話とかしながら回りましょう。",
    play_date: Date.today + 10,
    course_name: "戸塚カントリー倶楽部",
    prefecture: "神奈川県",
    needed_players: 3,
    status: "open",
  },
  {
    title: "ゴルフ始めたばかりです、一緒に練習しませんか",
    user: watanabe,
    description: "ゴルフ歴3ヶ月の初心者です。同じくらいのレベルの方や、教えてくれる方がいれば嬉しいです。まずはハーフからでも！",
    play_date: Date.today + 5,
    course_name: "富士OGMゴルフクラブ",
    prefecture: "静岡県",
    needed_players: 3,
    status: "open",
  },
  {
    title: "秋の紅葉ゴルフ🍂 景色重視で回りましょう",
    user: yamamoto,
    description: "紅葉が綺麗なコースでゆっくりラウンドしたいです。写真好きな方も大歓迎。スコアより雰囲気重視です。",
    play_date: Date.today + 21,
    course_name: "軽井沢72ゴルフ",
    prefecture: "長野県",
    needed_players: 2,
    status: "open",
  },
  {
    title: "【満員御礼】先週の続きでまたやりましょう！",
    user: test_user,
    description: "先週ご一緒した方々との再戦です。新規の方はご遠慮ください。",
    play_date: Date.today - 1,
    course_name: "東京ゴルフ倶楽部",
    prefecture: "東京都",
    needed_players: 3,
    status: "closed",
  },
]

recruitments.each do |recruitment|
  r = Recruitment.find_or_initialize_by(title: recruitment[:title], user_id: recruitment[:user].id)
  if r.new_record?
    r.assign_attributes(recruitment.except(:title, :user))
    r.user = recruitment[:user]
    r.save!(validate: false)
  end
end

puts "シードデータ作成完了！ユーザー#{users.size}件、募集#{recruitments.size}件"