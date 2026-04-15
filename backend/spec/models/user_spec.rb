require "rails_helper"

RSpec.describe User, type: :model do
  describe "バリデーション" do
    context "有効なデータの場合" do
      it "email と password があれば有効" do
        user = build(:user)
        expect(user).to be_valid
      end
    end

    context "email が不正な場合" do
      it "email が空だと無効" do
        user = build(:user, email: "")
        expect(user).not_to be_valid
        expect(user.errors[:email]).to be_present
      end

      it "重複した email は無効" do
        create(:user, email: "test@example.com")
        user = User.new(email: "test@example.com", password: "password123")
        user.valid?
        expect(user.errors[:email]).to include("has already been taken")
      end
    end

    context "password が不正な場合" do
      it "password が空だと無効" do
        user = build(:user, password: "")
        expect(user).not_to be_valid
        expect(user.errors[:password]).to be_present
      end

      it "password が 6 文字未満だと無効 (Devise デフォルト)" do
        user = build(:user, password: "abc", password_confirmation: "abc")
        expect(user).not_to be_valid
        expect(user.errors[:password]).to be_present
      end
    end
  end

  describe "アソシエーション" do
    it { is_expected.to have_one(:profile).dependent(:destroy) }
    it { is_expected.to have_many(:recruitments).dependent(:destroy) }
    it { is_expected.to have_many(:participations).dependent(:destroy) }
    it { is_expected.to have_many(:participated_recruitments).through(:participations) }
    it { is_expected.to have_many(:chat_members).dependent(:destroy) }
    it { is_expected.to have_many(:chats).through(:chat_members) }
    it { is_expected.to have_many(:messages).dependent(:destroy) }
    it { is_expected.to have_many(:notifications).dependent(:destroy) }
  end
end
