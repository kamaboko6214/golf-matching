<template>
  <div class="min-h-screen bg-gray-50">
    <!-- ヘッダー -->
    <header class="bg-green-900 text-white px-6 py-4 flex items-center justify-between">
      <div class="flex items-center gap-2">
        <span class="text-xl">⛳</span>
        <span class="font-black text-lg tracking-widest">GOLF<em class="not-italic text-lime-400">MATCH</em></span>
      </div>
      <div class="flex items-center gap-4">
        <router-link
          to="/matches/new"
          class="bg-lime-400 text-green-900 font-bold px-4 py-2 rounded-lg text-sm hover:bg-lime-300 transition"
        >
          + 募集を投稿
        </router-link>
        <button @click="logout" class="text-sm text-green-300 hover:text-white transition">
          ログアウト
        </button>
      </div>
    </header>

    <main class="max-w-4xl mx-auto px-4 py-8">
      <!-- ローディング -->
      <div v-if="loading" class="flex justify-center py-20">
        <div class="w-8 h-8 border-4 border-green-600 border-t-transparent rounded-full animate-spin"></div>
      </div>

      <!-- 空の場合 -->
      <div v-else-if="recruitments.length === 0" class="text-center py-20 text-gray-400">
        <p class="text-4xl mb-4">⛳</p>
        <p class="text-lg font-bold">まだ募集がありません</p>
        <p class="text-sm mt-2">最初の募集を投稿してみましょう！</p>
      </div>

      <!-- 一覧 -->
      <div v-else class="grid gap-4">
        <div
          v-for="r in recruitments"
          :key="r.id"
          @click="$router.push(`/matches/${r.id}`)"
          class="bg-white rounded-xl p-5 shadow-sm border border-gray-100 hover:shadow-md hover:border-green-200 transition cursor-pointer"
        >
          <div class="flex items-start justify-between gap-4">
            <div class="flex-1 min-w-0">
              <div class="flex items-center gap-2 mb-2">
                <span class="bg-green-100 text-green-800 text-xs font-bold px-2 py-1 rounded-full">
                  {{ r.prefecture }}
                </span>
                <span class="text-xs text-gray-400">{{ formatDate(r.play_date) }}</span>
              </div>
              <h2 class="font-bold text-gray-800 text-lg leading-tight truncate">{{ r.title }}</h2>
              <p class="text-gray-500 text-sm mt-1 line-clamp-2">{{ r.description }}</p>
            </div>
            <div class="text-right flex-shrink-0">
              <div class="text-2xl font-black text-green-700">{{ r.needed_players }}</div>
              <div class="text-xs text-gray-400">名募集</div>
            </div>
          </div>
          <div class="mt-3 pt-3 border-t border-gray-50 flex items-center justify-between">
            <span class="text-xs text-gray-400">📍 {{ r.course_name }}</span>
            <span class="text-xs text-gray-400">
              投稿者: {{ r.user?.name || r.user?.email }}
            </span>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import api from '../lib/api.js'

const router = useRouter()
const recruitments = ref([])
const loading = ref(true)

onMounted(async () => {
  try {
    const res = await api.get('/api/v1/recruitments')
    recruitments.value = res.data
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

const logout = () => {
  localStorage.removeItem('token')
  router.push('/login')
}
</script>