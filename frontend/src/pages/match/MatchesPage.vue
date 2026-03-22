<template>
  <div class="page-bg">
    <AppHeader>
      <router-link
        to="/matches/new"
        class="btn-primary"
        style="font-size: 0.8rem; padding: 0.5rem 1rem;"
      >
        + 募集を投稿
      </router-link>
    </AppHeader>

    <main class="max-w-5xl mx-auto px-4 py-6 flex flex-col lg:flex-row gap-6">
      <div class="flex-1 min-w-0">

        <!-- フィルターエリア -->
        <div class="glass-card p-4 mb-5">
          <div class="grid grid-cols-1 sm:grid-cols-3 gap-3">
            <div class="flex flex-col gap-1.5">
              <label class="label-dark">キーワード</label>
              <input
                v-model="filters.keyword"
                type="text"
                placeholder="タイトル・コース名で検索"
                class="input-dark"
                @input="debouncedSearch"
              />
            </div>
            <div class="flex flex-col gap-1.5">
              <label class="label-dark">都道府県</label>
              <select
                v-model="filters.prefecture"
                class="input-dark"
                @change="fetchRecruitments"
              >
                <option value="" :style="`background: var(--select-option-bg);`">すべて</option>
                <option v-for="pref in prefectures" :key="pref" :value="pref" :style="`background: var(--select-option-bg);`">{{ pref }}</option>
              </select>
            </div>
            <div class="flex flex-col gap-1.5">
              <label class="label-dark">プレー日</label>
              <input
                v-model="filters.from_date"
                type="date"
                class="input-dark"
                @change="fetchRecruitments"
              />
            </div>
          </div>

          <div class="flex justify-end mt-3">
            <button
              v-if="hasFilter"
              @click="resetFilters"
              class="text-xs font-bold transition"
              :style="`color: var(--text-faint);`"
            >
              ✕ フィルターをリセット
            </button>
          </div>
        </div>

        <!-- 件数表示 -->
        <p class="text-xs mb-4 tracking-wide" :style="`color: var(--text-faint);`">{{ recruitments.length }}件の募集</p>

        <!-- ローディング -->
        <div v-if="loading" class="flex justify-center py-20">
          <div class="w-8 h-8 border-2 rounded-full animate-spin" :style="`border-color: var(--border-card); border-top-color: #a3e635;`"></div>
        </div>

        <!-- 空の場合 -->
        <div v-else-if="recruitments.length === 0" class="text-center py-20" :style="`color: var(--text-faint);`">
          <p class="text-5xl mb-4">⛳</p>
          <p class="text-lg font-black" :style="`color: var(--text-muted);`">募集が見つかりません</p>
          <p class="text-sm mt-2">条件を変えて検索してみましょう</p>
        </div>

        <!-- 一覧 -->
        <div v-else class="grid gap-3">
          <div
            v-for="r in recruitments"
            :key="r.id"
            @click="$router.push(`/matches/${r.id}`)"
            class="glass-card glass-card-hover cursor-pointer overflow-hidden group"
          >
            <div v-if="r.image_url" class="h-36 overflow-hidden relative">
              <img :src="r.image_url" class="w-full h-full object-cover group-hover:scale-105 transition duration-500" />
              <div class="absolute inset-0" style="background: linear-gradient(to top, rgba(4,10,5,0.7) 0%, transparent 60%);"></div>
            </div>
            <div class="p-5">
              <div class="flex items-start justify-between gap-4">
                <div class="flex-1 min-w-0">
                  <div class="flex items-center gap-2 mb-2 flex-wrap">
                    <span class="badge-green">{{ r.prefecture }}</span>
                    <span class="text-xs" :style="`color: var(--text-faint);`">{{ formatDate(r.play_date) }}</span>
                  </div>
                  <h2 class="font-black text-base leading-tight truncate mb-1 c-text">{{ r.title }}</h2>
                  <p class="text-xs line-clamp-2 leading-relaxed" :style="`color: var(--text-muted);`">{{ r.description }}</p>
                </div>
                <div class="text-right flex-shrink-0">
                  <div class="text-3xl font-black c-text-accent" style="font-family: 'Bebas Neue', sans-serif; letter-spacing: 0.05em;">{{ r.needed_players }}</div>
                  <div class="text-xs" :style="`color: var(--text-faint);`">名募集</div>
                </div>
              </div>
              <div class="mt-3 pt-3 flex items-center justify-between" :style="`border-top: 1px solid var(--border-card);`">
                <span class="text-xs" :style="`color: var(--text-faint);`">📍 {{ r.course_name }}</span>
                <span
                  @click.stop="$router.push(`/users/${r.user.id}`)"
                  class="text-xs cursor-pointer transition hover:underline"
                  :style="`color: var(--text-muted);`"
                >
                  {{ r.user?.name || r.user?.email }}
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- サイドバー -->
      <div class="hidden lg:block w-60 flex-shrink-0">
        <div class="glass-card p-5 sticky top-20">
          <div class="text-center mb-4">
            <div class="w-14 h-14 rounded-full flex items-center justify-center mx-auto mb-3 text-2xl" :style="`background: var(--avatar-bg); border: 1px solid var(--avatar-border);`">
              🏌️
            </div>
            <p class="font-black text-sm c-text">{{ profile?.name || '名前未設定' }}</p>
            <p class="text-xs mt-1" :style="`color: var(--text-faint);`">{{ profile?.email }}</p>
          </div>
          <div class="space-y-2.5 py-4" :style="`border-top: 1px solid var(--border-card);`">
            <div class="flex justify-between items-center">
              <span class="text-xs" :style="`color: var(--text-muted);`">ハンデ</span>
              <span class="text-sm font-black c-text-accent">{{ profile?.handicap ?? '未設定' }}</span>
            </div>
            <div class="flex justify-between items-center">
              <span class="text-xs" :style="`color: var(--text-muted);`">エリア</span>
              <span class="text-sm font-bold c-text">{{ profile?.prefecture || '未設定' }}</span>
            </div>
          </div>
          <p v-if="profile?.bio" class="text-xs leading-relaxed py-3" :style="`color: var(--text-muted); border-top: 1px solid var(--border-card);`">
            {{ profile.bio }}
          </p>
          <router-link
            to="/profile"
            class="block mt-3 text-center text-xs font-black tracking-wide c-text-accent transition"
          >
            プロフィールを編集 →
          </router-link>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import api from '../../lib/api.js'
import AppHeader from '../../components/AppHeader.vue'
import { prefectures } from '../../constants/prefectures.js'

const recruitments = ref([])
const profile = ref(null)
const loading = ref(false)

const filters = ref({
  keyword: '',
  prefecture: '',
  from_date: '',
})

const hasFilter = computed(() =>
  filters.value.keyword || filters.value.prefecture || filters.value.from_date
)

let debounceTimer = null
const debouncedSearch = () => {
  clearTimeout(debounceTimer)
  debounceTimer = setTimeout(() => {
    fetchRecruitments()
  }, 400)
}

const fetchRecruitments = async () => {
  loading.value = true
  try {
    const params = {}
    if (filters.value.keyword) params.keyword = filters.value.keyword
    if (filters.value.prefecture) params.prefecture = filters.value.prefecture
    if (filters.value.from_date) params.from_date = filters.value.from_date
    const res = await api.get('/api/v1/recruitments', { params })
    recruitments.value = res.data
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
}

const resetFilters = () => {
  filters.value = { keyword: '', prefecture: '', from_date: '' }
  fetchRecruitments()
}

const formatDate = (dateStr) => {
  if (!dateStr) return ''
  const d = new Date(dateStr)
  return `${d.getFullYear()}年${d.getMonth() + 1}月${d.getDate()}日`
}

onMounted(async () => {
  const [_, profileRes] = await Promise.allSettled([
    fetchRecruitments(),
    api.get('/api/v1/profile')
  ])
  if (profileRes.status === 'fulfilled') {
    profile.value = profileRes.value.data
  }
})
</script>
