require "rails_helper"

RSpec.describe Recruitment, type: :model do
  describe "バリデーション" do
    context "有効なデータの場合" do
      it "すべての必須項目があれば有効" do
        recruitment = build(:recruitment)
        expect(recruitment).to be_valid
      end
    end

    context "title が不正な場合" do
      it "title が空だと無効" do
        recruitment = build(:recruitment, title: "")
        expect(recruitment).not_to be_valid
        expect(recruitment.errors[:title]).to be_present
      end

      it "titleが100文字を超えると無効" do
        recruitment = build(:recruitment, title: "a" * 101)
        expect(recruitment).not_to be_valid
      end
    end

    context "needed_players が不正な場合" do
      it "0だと無効" do
        recruitment = build(:recruitment, needed_players: 0)
        expect(recruitment).not_to be_valid
      end

      it "11以上だと無効" do
        recruitment = build(:recruitment, needed_players: 11)
        expect(recruitment).not_to be_valid
      end
    end

    context "play_date が不正な場合" do
      it "過去の日付だと無効" do
        recruitment = build(:recruitment, play_date: Date.yesterday)
        expect(recruitment).not_to be_valid
      end

      it "今日の日付だと有効" do
        recruitment = build(:recruitment, play_date: Date.today)
        expect(recruitment).to be_valid
      end

      it "未来の日付だと有効" do
        recruitment = build(:recruitment, play_date: Date.tomorrow)
        expect(recruitment).to be_valid
      end
    end
  end
end
