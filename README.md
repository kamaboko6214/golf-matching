# Golf Matching App

Rails API + Vue 3 SPA のゴルフマッチングアプリです。

## 技術スタック

| 層 | 技術 |
|---|---|
| バックエンド | Ruby on Rails 7.1 (API mode) |
| フロントエンド | Vue 3 + Vite |
| データベース | PostgreSQL 16 |
| 認証 | Devise + devise-jwt (JWT) |
| コンテナ | Docker / Docker Compose |

## ディレクトリ構成

```
golf-matching/
├── docker-compose.yml
├── .env.example
├── backend/              # Rails API
│   ├── Dockerfile
│   ├── Gemfile
│   ├── config/
│   │   ├── database.yml
│   │   └── initializers/
│   │       └── cors.rb
│   └── ...
└── frontend/             # Vue 3 SPA
    ├── Dockerfile
    ├── package.json
    ├── vite.config.js
    ├── index.html
    └── src/
        ├── main.js
        ├── App.vue
        ├── router/
        │   └── index.js
        ├── lib/
        │   └── api.js      # axios クライアント（JWT自動付与）
        └── pages/          # 各ページコンポーネント（今後追加）
```

## 起動手順

### 1. 環境変数の準備

```bash
cp .env.example .env
# .env を編集して DEVISE_JWT_SECRET_KEY を設定
```

### 2. Railsプロジェクトの新規作成（初回のみ）

```bash
docker compose run --rm backend \
  rails new . --api --database=postgresql --skip-git --force
```

### 3. コンテナ起動

```bash
docker compose up --build
```

### 4. 動作確認

- フロントエンド: http://localhost:5173
- Rails API:      http://localhost:3000

## よく使うコマンド

```bash
# Rails コンソール
docker compose exec backend rails console

# マイグレーション
docker compose exec backend rails db:migrate

# ログ確認
docker compose logs -f backend

# Gemを追加したら
docker compose build backend
docker compose up backend
```

## ポート一覧

| サービス | ポート |
|---|---|
| Vue (Vite dev server) | 5173 |
| Rails API | 3000 |
| PostgreSQL | 5432 |
