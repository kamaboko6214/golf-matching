<template>
  <div class="min-h-screen bg-gray-50">
    <AppHeader>
      <router-link to="/matches" class="text-sm text-green-300 hover:text-white transition">
        ← 一覧に戻る
      </router-link>
    </AppHeader>

    <main class="max-w-2xl mx-auto px-4 py-8">
      <!-- ローディング -->
      <div v-if="loading" class="flex justify-center py-20">
        <div
          class="w-8 h-8 border-4 border-green-600 border-t-transparent rounded-full animate-spin"
        ></div>
      </div>

      <template v-else-if="recruitment">
        <!-- メインカード -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6 mb-4">
          <div class="flex items-center gap-2 mb-3">
            <span class="bg-green-100 text-green-800 text-xs font-bold px-2 py-1 rounded-full">
              {{ recruitment.prefecture }}
            </span>
            <span class="text-xs text-gray-400">{{ formatDate(recruitment.play_date) }}</span>
            <span
              class="ml-auto text-xs font-bold px-2 py-1 rounded-full"
              :class="
                recruitment.status === 'open'
                  ? 'bg-lime-100 text-lime-800'
                  : 'bg-gray-100 text-gray-500'
              "
            >
              {{ recruitment.status === 'open' ? '募集中' : '締切' }}
            </span>
          </div>

          <h1 class="text-2xl font-black text-gray-800 mb-3">{{ recruitment.title }}</h1>
          <p class="text-gray-600 leading-relaxed mb-4">{{ recruitment.description }}</p>

          <div class="grid grid-cols-2 gap-3 py-4 border-t border-gray-50">
            <div class="flex flex-col gap-1">
              <span class="text-xs text-gray-400">コース</span>
              <span class="text-sm font-bold text-gray-700">📍 {{ recruitment.course_name }}</span>
            </div>
            <div class="flex flex-col gap-1">
              <span class="text-xs text-gray-400">募集人数</span>
              <span class="text-sm font-bold text-gray-700"
                >👥 {{ recruitment.needed_players }}名</span
              >
            </div>
            <div class="flex flex-col gap-1">
              <span class="text-xs text-gray-400">投稿者</span>
              <span class="text-sm font-bold text-gray-700">
                🏌️ {{ recruitment.user?.name || recruitment.user?.email }}
              </span>
            </div>
            <div class="flex flex-col gap-1">
              <span class="text-xs text-gray-400">参加申請</span>
              <span class="text-sm font-bold text-gray-700">
                {{ recruitment.participations_count }}名が申請中
              </span>
            </div>
          </div>
        </div>

        <!-- 参加ボタンエリア -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
          <!-- 自分の投稿 -->
          <div v-if="recruitment.is_owner" class="text-center text-gray-400 py-2">
            <p class="text-sm">あなたが投稿した募集です</p>
            <!-- 承認済みの人がいればチャットボタン -->
            <button
              v-if="approvedParticipation"
              @click="$router.push(`/chats/${approvedParticipation.chat_id}`)"
              class="mt-4 w-full bg-green-800 text-lime-400 font-black text-lg tracking-widest py-3 rounded-xl hover:bg-green-700 transition"
            >
              💬 チャットを確認する
            </button>
          </div>

          <!-- 申請していない -->
          <button
            v-else-if="!recruitment.my_participation && recruitment.status === 'open'"
            @click="applyParticipation"
            :disabled="applying"
            class="w-full bg-green-800 text-lime-400 font-black text-lg tracking-widest py-3 rounded-xl hover:bg-green-700 transition disabled:opacity-50"
          >
            <span v-if="applying">申請中...</span>
            <span v-else>参加を申請する</span>
          </button>

          <!-- 申請中 -->
          <div v-else-if="recruitment.my_participation === 'pending'" class="text-center py-2">
            <span
              class="inline-block bg-yellow-100 text-yellow-800 px-4 py-2 rounded-full text-sm font-bold"
            >
              ⏳ 申請中
            </span>
          </div>

          <!-- 承認済み → チャットボタン -->
          <div v-else-if="recruitment.my_participation === 'approved'" class="text-center py-2">
            <p class="text-green-700 font-bold mb-3">✅ 参加承認済み</p>
            <button
              @click="$router.push(`/chats/${recruitment.my_chat_id}`)"
              class="w-full bg-green-800 text-lime-400 font-black text-lg tracking-widest py-3 rounded-xl hover:bg-green-700 transition"
            >
              💬 チャットを開始する
            </button>
          </div>

          <!-- 却下 -->
          <div v-else-if="recruitment.my_participation === 'rejected'" class="text-center py-2">
            <span
              class="inline-block bg-red-100 text-red-700 px-4 py-2 rounded-full text-sm font-bold"
            >
              ❌ 申請が却下されました
            </span>
          </div>

          <!-- 募集締切 -->
          <div v-else class="text-center text-gray-400 py-2">
            <p class="text-sm">この募集は締め切られています</p>
          </div>

          <div
            v-if="errorMsg"
            class="mt-3 bg-red-50 text-red-600 text-sm px-4 py-3 rounded-lg border border-red-100"
          >
            {{ errorMsg }}
          </div>
        </div>
        <!-- 申請者一覧（投稿者のみ表示） -->
        <div
          v-if="recruitment.is_owner && recruitment.participations?.length > 0"
          class="bg-white rounded-xl shadow-sm border border-gray-100 p-6 mt-4"
        >
          <h2 class="font-black text-gray-800 mb-4">参加申請者一覧</h2>
          <div class="flex flex-col gap-3">
            <div
              v-for="p in recruitment.participations"
              :key="p.id"
              class="flex items-center justify-between py-3 border-b border-gray-50 last:border-0"
            >
              <div>
                <p class="font-bold text-sm text-gray-800">{{ p.user.name || p.user.email }}</p>
                <span
                  class="text-xs font-bold px-2 py-0.5 rounded-full"
                  :class="{
                    'bg-yellow-100 text-yellow-800': p.status === 'pending',
                    'bg-green-100 text-green-800': p.status === 'approved',
                    'bg-red-100 text-red-800': p.status === 'rejected',
                  }"
                >
                  {{
                    p.status === 'pending'
                      ? '申請中'
                      : p.status === 'approved'
                        ? '承認済み'
                        : '却下'
                  }}
                </span>
              </div>
              <div v-if="p.status === 'pending'" class="flex gap-2">
                <button
                  @click="updateParticipation(p.id, 'approved')"
                  class="bg-green-700 text-white text-xs font-bold px-3 py-1.5 rounded-lg hover:bg-green-600 transition"
                >
                  承認
                </button>
                <button
                  @click="updateParticipation(p.id, 'rejected')"
                  class="bg-red-100 text-red-700 text-xs font-bold px-3 py-1.5 rounded-lg hover:bg-red-200 transition"
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
  import api from '../lib/api.js'
  import AppHeader from '../components/AppHeader.vue'

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
