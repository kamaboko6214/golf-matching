class Api::V1::RecruitmentsController < ApplicationController
  before_action :authenticate_user!
  # show/edit/update/destroy では共通の募集取得処理を実行する
  before_action :set_recruitment, only: [:show, :edit, :update, :destroy]

  def index
    # N+1対策: user.profile・画像・participations を一括取得する
    recruitments = Recruitment.search(search_params).includes(user: { profile: { image_attachment: :blob } }, participations: { user: :profile })
    render json: recruitments.map { |r| recruitment_json(r, current_user) }
  end
  
  def show
    render json: recruitment_json(@recruitment, current_user)
  end

  # フロントエンドの編集フォーム用に現在値を返す
  def edit
    if @recruitment.user_id == current_user.id
      render json: edit_recruitment_json(@recruitment)
    else
      render json: { error: "権限がありません" }, status: :forbidden
    end
  end

  def create
    recruitment = current_user.recruitments.build(recruitment_params)
    if recruitment.save
      render json: recruitment_json(recruitment), status: :created
    else
      render json: { errors: recruitment.errors.full_messages }, status: :unprocessable_content
    end
  end
  
  def update
    if @recruitment.user_id == current_user.id
      if @recruitment.update(recruitment_params)
        render json: recruitment_json(@recruitment)
      else
        render json: { errors: @recruitment.errors.full_messages }, status: :unprocessable_content
      end
    else
      render json: { error: "権限がありません" }, status: :forbidden
    end
  end
  
  def destroy
    if @recruitment.user_id == current_user.id
      @recruitment.destroy
      render json: { message: "削除しました" }
    else
      render json: { error: "権限がありません" }, status: :forbidden
    end
  end
  
  private

  # N+1対策: 募集詳細ページで必要な関連データを一括取得する
  def set_recruitment
    @recruitment = Recruitment.includes(user: { profile: { image_attachment: :blob } }, participations: { user: :profile }).find(params[:id])
  end

  def search_params
    params.permit(:prefecture, :from_date, :to_date, :keyword)
  end

  def recruitment_params
    params.require(:recruitment).permit(
      :title, :description, :play_date,
      :course_name, :prefecture, :needed_players, :image
    )
  end

  # 募集情報のレスポンス形式を組み立てる
  # viewer を渡すことで「自分の申請状況」「オーナーかどうか」を付加できる
  def recruitment_json(recruitment, viewer = nil)
    {
      id: recruitment.id,
      title: recruitment.title,
      description: recruitment.description,
      play_date: recruitment.play_date,
      course_name: recruitment.course_name,
      prefecture: recruitment.prefecture,
      needed_players: recruitment.needed_players,
      status: recruitment.status,
      created_at: recruitment.created_at,
      user: {
        id: recruitment.user.id,
        email: recruitment.user.email,
        name: recruitment.user.profile&.name,
        image_url: profile_image_url(recruitment.user.profile)
      },
      # .size はインクルード済みの場合はSQLを発行せずメモリ内で数える
      participations_count: recruitment.participations.size,
      my_chat_id: recruitment.chat_id,
      # ロード済みの配列から検索することでN+1を防ぐ
      my_participation: viewer ? recruitment.participations.find { |p| p.user_id == viewer.id }&.status : nil,
      is_owner: viewer ? recruitment.user_id == viewer.id : false,
      # 投稿者にのみ申請者一覧を返す
      participations: viewer && recruitment.user_id == viewer.id ? participations_list(recruitment) : [],
      image_url: recruitment.image.attached? ? url_for(recruitment.image) : nil
    }
  end
  
  def edit_recruitment_json(recruitment)
    {
      id: recruitment.id,
      title: recruitment.title,
      description: recruitment.description,
      play_date: recruitment.play_date,
      course_name: recruitment.course_name,
      prefecture: recruitment.prefecture,
      needed_players: recruitment.needed_players,
      status: recruitment.status,
      image_url: recruitment.image.attached? ? url_for(recruitment.image) : nil
    }
  end

  def profile_image_url(profile)
    return nil unless profile&.image&.attached?

    url_for(profile.image)
  end

  def participations_list(recruitment)
    # includes済みのためSQLは発行されない
    recruitment.participations.map do |p|
      {
        id: p.id,
        status: p.status,
        chat_id: p.chat_id,
        user: {
          id: p.user.id,
          email: p.user.email,
          name: p.user.profile&.name,
          image_url: profile_image_url(p.user.profile)
        }
      }
    end
  end
end