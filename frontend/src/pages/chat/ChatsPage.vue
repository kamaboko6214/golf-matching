<template>
  <div class="page-bg">
    <AppHeader>
      <router-link to="/matches" class="text-xs font-bold transition" :style="`color: var(--text-muted);`">
        ← 一覧に戻る
      </router-link>
    </AppHeader>

    <main class="max-w-2xl mx-auto px-4 py-8">
      <h1 class="section-title mb-6" style="font-size: 1.8rem;">チャット一覧</h1>

      <div v-if="loading" class="flex justify-center py-20">
        <div class="w-8 h-8 border-2 rounded-full animate-spin" :style="`border-color: var(--border-card); border-top-color: #a3e635;`"></div>
      </div>

      <div v-else-if="chats.length === 0" class="text-center py-20" :style="`color: var(--text-faint);`">
        <p class="text-5xl mb-4">💬</p>
        <p class="text-lg font-black" :style="`color: var(--text-muted);`">チャットはまだありません</p>
        <p class="text-sm mt-2">募集に参加承認されるとチャットが始まります</p>
      </div>

      <div v-else class="flex flex-col gap-3">
        <div
          v-for="chat in chats"
          :key="chat.id"
          @click="$router.push(`/chats/${chat.id}`)"
          class="glass-card glass-card-hover cursor-pointer p-4"
        >
          <div class="flex items-center justify-between gap-3">
            <div class="flex items-center gap-3 min-w-0">
              <div
                class="w-10 h-10 rounded-full flex items-center justify-center text-lg flex-shrink-0"
                :style="`background: var(--avatar-bg); border: 1px solid var(--avatar-border);`"
              >
                🏌️
              </div>
              <div class="min-w-0">
                <p class="font-black text-sm truncate c-text">
                  {{ chat.recruitment_title || 'チャット' }}
                </p>
                <p class="text-xs mt-0.5 truncate" :style="`color: var(--text-muted);`">
                  {{ chat.members.map((m) => m.name).join('、') }}
                </p>
                <p class="text-xs mt-0.5 line-clamp-1" :style="`color: var(--text-faint);`">
                  {{ chat.last_message?.body || 'メッセージはまだありません' }}
                </p>
              </div>
            </div>
            <span class="text-xs flex-shrink-0" :style="`color: var(--text-faint);`">
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
  import api from '../../lib/api.js'
  import AppHeader from '../../components/AppHeader.vue'

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

  const formatDate = (dateStr) => {
    if (!dateStr) return ''
    const d = new Date(dateStr)
    return `${d.getMonth() + 1}/${d.getDate()}`
  }
</script>
