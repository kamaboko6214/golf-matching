<template>
  <div class="page-bg">
    <AppHeader>
      <router-link to="/matches" class="text-xs font-bold transition" :style="`color: var(--text-muted);`">
        ← 一覧に戻る
      </router-link>
    </AppHeader>

    <main class="max-w-2xl mx-auto px-4 py-8">
      <h1 class="section-title mb-6" style="font-size: 1.8rem;">マイページ</h1>

      <div v-if="loading" class="flex justify-center py-20">
        <div class="w-8 h-8 border-2 rounded-full animate-spin"
          :style="`border-color: var(--border-card); border-top-color: #a3e635;`"></div>
      </div>

      <template v-else>
        <!-- 参加予定 -->
        <section class="mb-8">
          <h2 class="flex items-center gap-2 mb-3">
            <span class="text-lime-500 text-base">✅</span>
            <span class="section-title" style="font-size: 1.1rem;">参加予定</span>
            <span class="text-xs font-normal ml-1" :style="`color: var(--text-faint);`">承認済み</span>
          </h2>
          <div v-if="data.approved_participations.length === 0" class="text-sm py-4 text-center glass-card p-4"
            :style="`color: var(--text-faint);`">
            参加予定の募集はありません
          </div>
          <div v-else class="flex flex-col gap-3">
            <div v-for="p in data.approved_participations" :key="p.id" class="glass-card p-4">
              <div class="flex items-center justify-between gap-3">
                <div class="min-w-0">
                  <p class="font-black text-sm truncate c-text">{{ p.recruitment.title }}</p>
                  <p class="text-xs mt-1" :style="`color: var(--text-faint);`">
                    📍 {{ p.recruitment.prefecture }} · {{ formatDate(p.recruitment.play_date) }}
                  </p>
                </div>
                <button @click="$router.push(`/chats/${p.chat_id}`)" class="btn-primary flex-shrink-0"
                  style="font-size: 0.75rem; padding: 0.45rem 0.9rem;">
                  💬 チャット
                </button>
              </div>
            </div>
          </div>
        </section>

        <!-- 申請中 -->
        <section class="mb-8">
          <h2 class="flex items-center gap-2 mb-3">
            <span class="text-yellow-500 text-base">⏳</span>
            <span class="section-title" style="font-size: 1.1rem;">申請中</span>
          </h2>
          <div v-if="data.pending_participations.length === 0" class="text-sm py-4 text-center glass-card p-4"
            :style="`color: var(--text-faint);`">
            申請中の募集はありません
          </div>
          <div v-else class="flex flex-col gap-3">
            <div v-for="p in data.pending_participations" :key="p.id"
              @click="$router.push(`/matches/${p.recruitment.id}`)"
              class="glass-card glass-card-hover cursor-pointer p-4">
              <p class="font-black text-sm c-text">{{ p.recruitment.title }}</p>
              <p class="text-xs mt-1" :style="`color: var(--text-faint);`">
                📍 {{ p.recruitment.prefecture }} · {{ formatDate(p.recruitment.play_date) }}
              </p>
            </div>
          </div>
        </section>

        <!-- 自分の投稿 -->
        <section>
          <h2 class="flex items-center gap-2 mb-3">
            <span class="text-base">🏌️</span>
            <span class="section-title" style="font-size: 1.1rem;">自分の投稿</span>
          </h2>
          <div v-if="data.posted_recruitments.length === 0" class="text-sm py-4 text-center glass-card p-4"
            :style="`color: var(--text-faint);`">
            投稿した募集はありません
          </div>
          <div v-else class="flex flex-col gap-3">
            <div v-for="r in data.posted_recruitments" :key="r.id" @click="$router.push(`/matches/${r.id}`)"
              class="glass-card glass-card-hover cursor-pointer p-4">
              <div class="flex items-center justify-between gap-3">
                <div class="min-w-0">
                  <p class="font-black text-sm truncate c-text">{{ r.title }}</p>
                  <p class="text-xs mt-1" :style="`color: var(--text-faint);`">
                    📍 {{ r.prefecture }} · {{ formatDate(r.play_date) }}
                  </p>
                </div>
                <div class="text-right flex-shrink-0">
                  <span class="text-xs font-bold px-2.5 py-0.5 rounded-full inline-block"
                    :class="r.status === 'open'
                      ? 'bg-green-100 text-green-700 border border-green-200 dark:bg-lime-400/20 dark:text-lime-400 dark:border-lime-400/30'
                      : 'bg-gray-100 text-gray-500 border border-gray-200 dark:bg-green-900/40 dark:text-green-600 dark:border-green-800/30'">
                    {{ r.status === 'open' ? '募集中' : '締切' }}
                  </span>
                  <p class="text-xs mt-1" :style="`color: var(--text-faint);`">{{ r.participations_count }}名申請中</p>
                </div>
              </div>
            </div>
          </div>
        </section>
      </template>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import api from '../../lib/api.js'
import AppHeader from '../../components/AppHeader.vue'

const loading = ref(true)
const data = ref({
  posted_recruitments: [],
  pending_participations: [],
  approved_participations: [],
})

onMounted(async () => {
  try {
    const res = await api.get('/api/v1/my_page')
    data.value = res.data
    console.log(res.data)
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
})

const formatDate = (dateStr) => {
  if (!dateStr) return ''
  const d = new Date(dateStr)
  return `${d.getFullYear()}年${d.getMonth() + 1}月${d.getDate()}日`
}
</script>
