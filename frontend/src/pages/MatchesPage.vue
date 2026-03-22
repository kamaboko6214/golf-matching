<template>
  <div class="min-h-screen bg-gray-50">
    <AppHeader>
      <router-link
        to="/matches/new"
        class="bg-lime-400 text-green-900 font-bold px-4 py-2 rounded-lg text-sm hover:bg-lime-300 transition"
      >
        + 募集を投稿
      </router-link>
    </AppHeader>

    <main class="max-w-5xl mx-auto px-4 py-8 flex gap-6">
      <!-- 左: 募集一覧 -->
      <div class="flex-1 min-w-0">
        <div v-if="loading" class="flex justify-center py-20">
          <div
            class="w-8 h-8 border-4 border-green-600 border-t-transparent rounded-full animate-spin"
          ></div>
        </div>

        <div v-else-if="recruitments.length === 0" class="text-center py-20 text-gray-400">
          <p class="text-4xl mb-4">⛳</p>
          <p class="text-lg font-bold">まだ募集がありません</p>
          <p class="text-sm mt-2">最初の募集を投稿してみましょう！</p>
        </div>

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
                  <span
                    class="bg-green-100 text-green-800 text-xs font-bold px-2 py-1 rounded-full"
                  >
                    {{ r.prefecture }}
                  </span>
                  <span class="text-xs text-gray-400">{{ formatDate(r.play_date) }}</span>
                </div>
                <h2 class="font-bold text-gray-800 text-lg leading-tight truncate">
                  {{ r.title }}
                </h2>
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
      </div>

      <!-- 右: プロフィール -->
      <div class="w-64 flex-shrink-0">
        <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-5 sticky top-6">
          <div class="text-center mb-4">
            <div
              class="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-3 text-2xl"
            >
              🏌️
            </div>
            <p class="font-black text-gray-800">{{ profile?.name || '名前未設定' }}</p>
            <p class="text-xs text-gray-400 mt-1">{{ profile?.email }}</p>
          </div>

          <div class="space-y-2 py-4 border-t border-gray-50">
            <div class="flex justify-between items-center">
              <span class="text-xs text-gray-400">ハンデ</span>
              <span class="text-sm font-bold text-gray-700">
                {{ profile?.handicap ?? '未設定' }}
              </span>
            </div>
            <div class="flex justify-between items-center">
              <span class="text-xs text-gray-400">エリア</span>
              <span class="text-sm font-bold text-gray-700">
                {{ profile?.prefecture || '未設定' }}
              </span>
            </div>
          </div>

          <p
            v-if="profile?.bio"
            class="text-xs text-gray-500 leading-relaxed py-3 border-t border-gray-50"
          >
            {{ profile.bio }}
          </p>

          <router-link
            to="/profile"
            class="block mt-3 text-center text-xs font-bold text-green-700 hover:text-green-900 transition"
          >
            プロフィールを編集 →
          </router-link>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
  import { ref, onMounted } from 'vue'
  import { useRouter } from 'vue-router'
  import api from '../lib/api.js'
  import AppHeader from '../components/AppHeader.vue'

  const router = useRouter()
  const recruitments = ref([])
  const profile = ref(null)
  const loading = ref(true)

  onMounted(async () => {
    try {
      const [recruitmentsRes, profileRes] = await Promise.all([
        api.get('/api/v1/recruitments'),
        api.get('/api/v1/profile'),
      ])
      recruitments.value = recruitmentsRes.data
      profile.value = profileRes.data
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
