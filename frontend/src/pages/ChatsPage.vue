<template>
  <div class="min-h-screen bg-gray-50">
    <AppHeader />

    <main class="max-w-2xl mx-auto px-4 py-8">
      <h1 class="text-2xl font-black text-green-900 mb-6">チャット一覧</h1>

      <div v-if="loading" class="flex justify-center py-20">
        <div
          class="w-8 h-8 border-4 border-green-600 border-t-transparent rounded-full animate-spin"
        ></div>
      </div>

      <div v-else-if="chats.length === 0" class="text-center py-20 text-gray-400">
        <p class="text-4xl mb-4">💬</p>
        <p class="text-lg font-bold">チャットはまだありません</p>
        <p class="text-sm mt-2">募集に参加承認されるとチャットが始まります</p>
      </div>

      <div v-else class="flex flex-col gap-3">
        <div
          v-for="chat in chats"
          :key="chat.id"
          @click="$router.push(`/chats/${chat.id}`)"
          class="bg-white rounded-xl p-5 shadow-sm border border-gray-100 hover:shadow-md hover:border-green-200 transition cursor-pointer"
        >
          <div class="flex items-center justify-between">
            <div class="flex items-center gap-3">
              <div
                class="w-10 h-10 bg-green-100 rounded-full flex items-center justify-center text-lg"
              >
                🏌️
              </div>
              <div>
                <p class="font-bold text-gray-800 text-sm">
                  {{ chat.recruitment_title || 'チャット' }}
                </p>
                <p class="text-xs text-gray-400 mt-0.5">
                  {{ chat.members.map((m) => m.name).join('、') }}
                </p>

                <p class="text-xs text-gray-400 mt-0.5 line-clamp-1">
                  {{ chat.last_message?.body || 'メッセージはまだありません' }}
                </p>
              </div>
            </div>
            <span class="text-xs text-gray-400">
              {{ chat.last_message ? formatDate(chat.last_message.created_at) : '' }}
            </span>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
  import { ref, onMounted } from 'vue'
  import api from '../lib/api.js'
  import AppHeader from '../components/AppHeader.vue'

  const chats = ref([])
  const loading = ref(true)

  onMounted(async () => {
    try {
      const res = await api.get('/api/v1/chats')
      chats.value = res.data
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
    return `${d.getMonth() + 1}/${d.getDate()}`
  }
</script>
