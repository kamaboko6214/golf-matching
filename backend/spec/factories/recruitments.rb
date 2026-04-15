FactoryBot.define do
  factory :recruitment do
    association :user
    title { "テスト募集" }
    description { "テスト説明" }
    needed_players { 4 }
    play_date { Date.today + 7 }
    prefecture { "東京都" }
    status { "open" }
  end
end