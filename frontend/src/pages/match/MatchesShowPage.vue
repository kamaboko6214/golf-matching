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

      <template v-else-if="recruitment">
        <!-- メインカード -->
        <div class="glass-card overflow-hidden mb-4">
          <div v-if="recruitment.image_url" class="relative h-52">
            <img :src="recruitment.image_url" class="w-full h-full object-cover" />
            <div class="absolute inset-0" style="background: linear-gradient(to top, rgba(4,10,5,0.9) 0%, transparent 55%);"></div>
            <div class="absolute bottom-0 left-0 right-0 p-5">
              <div class="flex items-center gap-2 mb-1.5">
                <span class="badge-green">{{ recruitment.prefecture }}</span>
                <span class="text-xs text-green-400">{{ formatDate(recruitment.play_date) }}</span>
                <span
                  class="ml-auto text-xs font-bold px-2.5 py-0.5 rounded-full"
                  :class="recruitment.status === 'open'
                    ? 'bg-lime-400/20 text-lime-400 border border-lime-400/30'
                    : 'bg-white/10 text-white/60 border border-white/20'"
                >
                  {{ recruitment.status === 'open' ? '募集中' : '締切' }}
                </span>
              </div>
              <h1 class="text-2xl font-black text-white" style="font-family: 'Bebas Neue', sans-serif; letter-spacing: 0.05em;">{{ recruitment.title }}</h1>
            </div>
          </div>

          <div class="p-6">
            <template v-if="!recruitment.image_url">
              <div class="flex items-center gap-2 mb-3">
                <span class="badge-green">{{ recruitment.prefecture }}</span>
                <span class="text-xs" :style="`color: var(--text-faint);`">{{ formatDate(recruitment.play_date) }}</span>
                <span
                  class="ml-auto text-xs font-bold px-2.5 py-0.5 rounded-full"
                  :class="recruitment.status === 'open'
                    ? 'bg-green-100 text-green-700 border border-green-200 dark:bg-lime-400/20 dark:text-lime-400 dark:border-lime-400/30'
                    : 'bg-gray-100 text-gray-500 border border-gray-200 dark:bg-green-900/40 dark:text-green-600 dark:border-green-800/30'"
                >
                  {{ recruitment.status === 'open' ? '募集中' : '締切' }}
                </span>
              </div>
              <h1 class="text-2xl font-black mb-3 c-text" style="font-family: 'Bebas Neue', sans-serif; letter-spacing: 0.05em;">{{ recruitment.title }}</h1>
            </template>

            <p class="text-sm leading-relaxed mb-5" :style="`color: var(--text-muted);`">{{ recruitment.description }}</p>

            <div class="grid grid-cols-2 gap-3 py-4" :style="`border-top: 1px solid var(--border-card);`">
              <div class="flex flex-col gap-1">
                <span class="label-dark">コース</span>
                <span class="text-sm font-bold c-text">📍 {{ recruitment.course_name }}</span>
              </div>
              <div class="flex flex-col gap-1">
                <span class="label-dark">募集人数</span>
                <span class="font-black c-text-accent" style="font-family: 'Bebas Neue', sans-serif; font-size: 1.3rem; letter-spacing: 0.05em;">
                  {{ recruitment.needed_players }}<span class="text-sm font-normal ml-1 c-text-muted" style="font-family: inherit;">名</span>
                </span>
              </div>
              <div class="flex flex-col gap-1">
                <span class="label-dark">投稿者</span>
                <span
                  class="text-sm font-bold transition hover:underline cursor-pointer"
                  :style="`color: var(--text);`"
                  @click.stop="$router.push(`/users/${recruitment.user.id}`)"
                >
                  🏌️ {{ recruitment.user?.name || recruitment.user?.email }}
                </span>
              </div>
              <div class="flex flex-col gap-1">
                <span class="label-dark">参加申請</span>
                <span class="text-sm font-bold c-text">{{ recruitment.participations_count }}名が申請中</span>
              </div>
            </div>
          </div>
        </div>

        <!-- 参加ボタンエリア -->
        <div class="glass-card p-6 mb-4">
          <div v-if="recruitment.is_owner" class="text-center">
            <p class="text-sm mb-4" :style="`color: var(--text-muted);`">あなたが投稿した募集です</p>
            <button
              v-if="approvedParticipation"
              @click="$router.push(`/chats/${approvedParticipation.chat_id}`)"
              class="btn-primary w-full"
            >
              💬 チャットを確認する
            </button>
          </div>

          <button
            v-else-if="!recruitment.my_participation && recruitment.status === 'open'"
            @click="applyParticipation"
            :disabled="applying"
            class="btn-primary w-full"
          >
            <span v-if="applying" class="flex items-center justify-center gap-2">
              <span class="w-4 h-4 border-2 border-green-900/30 border-t-green-900 rounded-full animate-spin"></span>
              申請中...
            </span>
            <span v-else>参加を申請する</span>
          </button>

          <div v-else-if="recruitment.my_participation === 'pending'" class="text-center py-2">
            <span class="inline-flex items-center gap-2 px-5 py-2.5 rounded-full text-sm font-bold bg-yellow-100 text-yellow-800 border border-yellow-200 dark:bg-yellow-900/30 dark:text-yellow-400 dark:border-yellow-700/30">
              ⏳ 申請中 — 承認をお待ちください
            </span>
          </div>

          <div v-else-if="recruitment.my_participation === 'approved'" class="text-center">
            <p class="font-bold text-sm mb-3 c-text-accent">✅ 参加承認済み</p>
            <button
              @click="$router.push(`/chats/${recruitment.my_chat_id}`)"
              class="btn-primary w-full"
            >
              💬 チャットを開始する
            </button>
          </div>

          <div v-else-if="recruitment.my_participation === 'rejected'" class="text-center py-2">
            <span class="inline-flex items-center gap-2 px-5 py-2.5 rounded-full text-sm font-bold bg-red-100 text-red-700 border border-red-200 dark:bg-red-950/40 dark:text-red-400 dark:border-red-800/30">
              ❌ 申請が却下されました
            </span>
          </div>

          <div v-else class="text-center py-2" :style="`color: var(--text-muted);`">
            <p class="text-sm">この募集は締め切られています</p>
          </div>

          <div v-if="errorMsg" class="mt-3 text-sm px-4 py-3 rounded-lg bg-red-100 text-red-700 border border-red-200 dark:bg-red-950/30 dark:text-red-400 dark:border-red-800/30">
            {{ errorMsg }}
          </div>
        </div>

        <!-- 申請者一覧（投稿者のみ） -->
        <div
          v-if="recruitment.is_owner && recruitment.participations?.length > 0"
          class="glass-card p-6"
        >
          <h2 class="section-title mb-4">参加申請者一覧</h2>
          <div class="flex flex-col gap-3">
            <div
              v-for="p in recruitment.participations"
              :key="p.id"
              class="flex items-center justify-between py-3 last:border-0"
              :style="`border-bottom: 1px solid var(--border-card);`"
            >
              <div>
                <p class="font-bold text-sm c-text">{{ p.user.name || p.user.email }}</p>
                <span
                  class="text-xs font-bold px-2.5 py-0.5 rounded-full mt-1 inline-block"
                  :class="{
                    'bg-yellow-100 text-yellow-800 border border-yellow-200 dark:bg-yellow-900/30 dark:text-yellow-400 dark:border-yellow-700/30': p.status === 'pending',
                    'bg-green-100 text-green-700 border border-green-200 dark:bg-lime-900/30 dark:text-lime-400 dark:border-lime-700/30': p.status === 'approved',
                    'bg-red-100 text-red-700 border border-red-200 dark:bg-red-950/30 dark:text-red-400 dark:border-red-800/30': p.status === 'rejected',
                  }"
                >
                  {{ p.status === 'pending' ? '申請中' : p.status === 'approved' ? '承認済み' : '却下' }}
                </span>
              </div>
              <div v-if="p.status === 'pending'" class="flex gap-2">
                <button
                  @click="updateParticipation(p.id, 'approved')"
                  class="bg-lime-400 text-green-950 text-xs font-black px-3 py-1.5 rounded-lg hover:brightness-110 transition"
                >
                  承認
                </button>
                <button
                  @click="updateParticipation(p.id, 'rejected')"
                  class="text-xs font-bold px-3 py-1.5 rounded-lg transition bg-red-100 text-red-700 border border-red-200 dark:bg-red-950/40 dark:text-red-400 dark:border-red-800/30 hover:opacity-80"
                >
                  却下
                </button>
              </div>
            </div>
          </div>
        </div>
      </template>
    </main>
  </div>
</template>

<script setup>
  import { ref, onMounted, computed } from 'vue'
  import { useRoute } from 'vue-router'
  import api from '../../lib/api.js'
  import AppHeader from '../../components/AppHeader.vue'

  const route = useRoute()
  const recruitment = ref(null)
  const loading = ref(true)
  const applying = ref(false)
  const errorMsg = ref('')

  onMounted(async () => {
    try {
      const res = await api.get(`/api/v1/recruitments/${route.params.id}`)
      recruitment.value = res.data
    } catch (e) {
      console.error(e)
    } finally {
      loading.value = false
    }
  })

  const approvedParticipation = computed(() =>
    recruitment.value?.participations?.find((p) => p.status === 'approved')
  )
  async function applyParticipation() {
    applying.value = true
    errorMsg.value = ''
    try {
      await api.post(`/api/v1/recruitments/${route.params.id}/participations`)
      const res = await api.get(`/api/v1/recruitments/${route.params.id}`)
      recruitment.value = res.data
    } catch (e) {
      errorMsg.value = e.response?.data?.error || 'エラーが発生しました'
    } finally {
      applying.value = false
    }
  }
  async function updateParticipation(participationId, status) {
    try {
      await api.patch(`/api/v1/participations/${participationId}`, { status })
      const res = await api.get(`/api/v1/recruitments/${route.params.id}`)
      recruitment.value = res.data
    } catch (e) {
      errorMsg.value = e.response?.data?.error || 'エラーが発生しました'
    }
  }

  function formatDate(dateStr) {
    if (!dateStr) return ''
    const d = new Date(dateStr)
    return `${d.getFullYear()}年${d.getMonth() + 1}月${d.getDate()}日`
  }
</script>
