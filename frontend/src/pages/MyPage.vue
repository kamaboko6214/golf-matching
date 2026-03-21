<template>
  <div class="min-h-screen bg-gray-50">
    <AppHeader />

    <main class="max-w-2xl mx-auto px-4 py-8">
      <h1 class="text-2xl font-black text-green-900 mb-6">マイページ</h1>

      <div v-if="loading" class="flex justify-center py-20">
        <div
          class="w-8 h-8 border-4 border-green-600 border-t-transparent rounded-full animate-spin"
        ></div>
      </div>

      <template v-else>
        <!-- 参加予定 -->
        <section class="mb-8">
          <h2 class="text-lg font-black text-gray-700 mb-3 flex items-center gap-2">
            ✅ 参加予定
            <span class="text-xs font-normal text-gray-400">承認済み</span>
          </h2>
          <div
            v-if="data.approved_participations.length === 0"
            class="text-sm text-gray-400 py-4 text-center"
          >
            参加予定の募集はありません
          </div>
          <div v-else class="flex flex-col gap-3">
            <div
              v-for="p in data.approved_participations"
              :key="p.id"
              class="bg-white rounded-xl p-4 shadow-sm border border-gray-100"
            >
              <div class="flex items-center justify-between">
                <div>
                  <p class="font-bold text-gray-800">{{ p.recruitment.title }}</p>
                  <p class="text-xs text-gray-400 mt-1">
                    📍 {{ p.recruitment.prefecture }} ・ {{ formatDate(p.recruitment.play_date) }}
                  </p>
                </div>
                <button
                  @click="$router.push(`/chats/${p.chat_id}`)"
                  class="bg-green-800 text-lime-400 text-xs font-bold px-3 py-2 rounded-lg hover:bg-green-700 transition flex-shrink-0"
                >
                  💬 チャット
                </button>
              </div>
            </div>
          </div>
        </section>

        <!-- 申請中 -->
        <section class="mb-8">
          <h2 class="text-lg font-black text-gray-700 mb-3 flex items-center gap-2">⏳ 申請中</h2>
          <div
            v-if="data.pending_participations.length === 0"
            class="text-sm text-gray-400 py-4 text-center"
          >
            申請中の募集はありません
          </div>
          <div v-else class="flex flex-col gap-3">
            <div
              v-for="p in data.pending_participations"
              :key="p.id"
              @click="$router.push(`/matches/${p.recruitment.id}`)"
              class="bg-white rounded-xl p-4 shadow-sm border border-gray-100 hover:border-green-200 transition cursor-pointer"
            >
              <p class="font-bold text-gray-800">{{ p.recruitment.title }}</p>
              <p class="text-xs text-gray-400 mt-1">
                📍 {{ p.recruitment.prefecture }} ・ {{ formatDate(p.recruitment.play_date) }}
              </p>
            </div>
          </div>
        </section>

        <!-- 自分の投稿 -->
        <section>
          <h2 class="text-lg font-black text-gray-700 mb-3 flex items-center gap-2">
            🏌️ 自分の投稿
          </h2>
          <div
            v-if="data.posted_recruitments.length === 0"
            class="text-sm text-gray-400 py-4 text-center"
          >
            投稿した募集はありません
          </div>
          <div v-else class="flex flex-col gap-3">
            <div
              v-for="r in data.posted_recruitments"
              :key="r.id"
              @click="$router.push(`/matches/${r.id}`)"
              class="bg-white rounded-xl p-4 shadow-sm border border-gray-100 hover:border-green-200 transition cursor-pointer"
            >
              <div class="flex items-center justify-between">
                <div>
                  <p class="font-bold text-gray-800">{{ r.title }}</p>
                  <p class="text-xs text-gray-400 mt-1">
                    📍 {{ r.prefecture }} ・ {{ formatDate(r.play_date) }}
                  </p>
                </div>
                <div class="text-right flex-shrink-0">
                  <span
                    class="text-xs font-bold px-2 py-1 rounded-full"
                    :class="
                      r.status === 'open'
                        ? 'bg-lime-100 text-lime-800'
                        : 'bg-gray-100 text-gray-500'
                    "
                  >
                    {{ r.status === 'open' ? '募集中' : '締切' }}
                  </span>
                  <p class="text-xs text-gray-400 mt-1">{{ r.participations_count }}名申請中</p>
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
  import { useRouter } from 'vue-router'
  import api from '../lib/api.js'
  import AppHeader from '../components/AppHeader.vue'

  const router = useRouter()
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

  function formatDate(dateStr) {
    if (!dateStr) return ''
    const d = new Date(dateStr)
    return `${d.getFullYear()}年${d.getMonth() + 1}月${d.getDate()}日`
  }
</script>
