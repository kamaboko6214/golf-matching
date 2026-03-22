<template>
  <div class="page-bg">
    <AppHeader>
      <router-link to="/matches" class="text-xs font-bold transition" :style="`color: var(--text-muted);`">
        ← 一覧に戻る
      </router-link>
    </AppHeader>

    <main class="max-w-2xl mx-auto px-4 py-8">
      <div v-if="loading" class="flex justify-center py-20">
        <div class="w-8 h-8 border-2 rounded-full animate-spin" :style="`border-color: var(--border-card); border-top-color: #a3e635;`"></div>
      </div>

      <template v-else-if="user">
        <div class="glass-card p-6 mb-6">
          <div class="flex items-center gap-4">
            <div
              class="w-16 h-16 rounded-full flex items-center justify-center text-3xl flex-shrink-0"
              :style="`background: var(--avatar-bg); border: 2px solid var(--avatar-border);`"
            >
              🏌️
            </div>
            <div>
              <h1 class="text-xl font-black c-text" style="font-family: 'Bebas Neue', sans-serif; letter-spacing: 0.05em;">
                {{ user.name || '名前未設定' }}
              </h1>
              <p class="text-sm mt-1" :style="`color: var(--text-faint);`">{{ user.email }}</p>
            </div>
          </div>

          <div class="grid grid-cols-2 gap-4 mt-5 py-4" :style="`border-top: 1px solid var(--border-card);`">
            <div class="flex flex-col gap-1">
              <span class="label-dark">ハンデ</span>
              <span class="text-lg font-black c-text-accent" style="font-family: 'Bebas Neue', sans-serif; letter-spacing: 0.05em;">
                {{ user.handicap ?? '未設定' }}
              </span>
            </div>
            <div class="flex flex-col gap-1">
              <span class="label-dark">エリア</span>
              <span class="text-sm font-bold c-text">{{ user.prefecture || '未設定' }}</span>
            </div>
          </div>

          <div v-if="user.bio" class="mt-4 pt-4" :style="`border-top: 1px solid var(--border-card);`">
            <p class="label-dark mb-2">自己紹介</p>
            <p class="text-sm leading-relaxed" :style="`color: var(--text-muted);`">{{ user.bio }}</p>
          </div>
        </div>

        <div v-if="user.recruitments.length > 0">
          <h2 class="section-title mb-3" style="font-size: 1.1rem;">募集中のラウンド</h2>
          <div class="flex flex-col gap-3">
            <div
              v-for="r in user.recruitments"
              :key="r.id"
              @click="$router.push(`/matches/${r.id}`)"
              class="glass-card glass-card-hover cursor-pointer p-4"
            >
              <p class="font-black text-sm c-text">{{ r.title }}</p>
              <div class="flex items-center gap-3 mt-2">
                <span class="badge-green">{{ r.prefecture }}</span>
                <span class="text-xs" :style="`color: var(--text-faint);`">{{ formatDate(r.play_date) }}</span>
                <span class="text-xs ml-auto" :style="`color: var(--text-faint);`">👥 {{ r.needed_players }}名募集</span>
              </div>
            </div>
          </div>
        </div>
      </template>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import api from '../../lib/api.js'
import AppHeader from '../../components/AppHeader.vue'

const route = useRoute()
const user = ref(null)
const loading = ref(true)

onMounted(async () => {
  try {
    const res = await api.get(`/api/v1/users/${route.params.id}`)
    user.value = res.data
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
})

function formatDate(dateStr) {
  if (!dateStr) return ''
  const d = new Date(dateStr)
  return `${d.getFullYear()}年${d.getMonth() + 1}月${d.getDate()}日`
}
</script>
