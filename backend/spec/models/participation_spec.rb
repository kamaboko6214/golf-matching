require "rails_helper"

RSpec.describe Participation, type: :model do
  describe "バリデーション" do
    context "有効なデータの場合" do
      it "すべての必須項目があれば有効" do
        user = create(:user)
        recruitment = create(:recruitment)
        participation = build(:participation, user: user, recruitment: recruitment)
        expect(participation).to be_valid
      end
    end

    context "ユーザーが自分の募集に参加しようとする場合" do
      it "無効" do
        user = create(:user)
        recruitment = create(:recruitment, user: user)
        participation = build(:participation, user: user, recruitment: recruitment)
        expect(participation).not_to be_valid
        expect(participation.errors[:base]).to include("自分の募集には参加できません")
      end
    end

    context "ユーザーが同じ募集に複数回参加しようとする場合" do
      it "無効" do
          user = create(:user)
          recruitment = create(:recruitment)
          create(:participation, user: user, recruitment: recruitment)
          #同じユーザーと募集で新しい参加を作成しようとすると、バリデーションエラーになることを確認
          duplicate_participation = build(:participation, user: user, recruitment: recruitment)
          expect(duplicate_participation).not_to be_valid
          expect(duplicate_participation.errors[:base]).to include("すでに申請済みです")
      end
    end
  end
end
