<template>
  <div class="page-bg flex flex-col" style="height: 100vh;">
    <AppHeader>
      <router-link to="/matches" class="text-xs font-bold transition" :style="`color: var(--text-muted);`">
        ← 一覧に戻る
      </router-link>
    </AppHeader>

    <main class="flex-1 max-w-2xl w-full mx-auto px-4 py-4 flex flex-col overflow-hidden">
      <!-- リクルート詳細 -->
      <div v-if="recruitment" class="glass-card p-4 mb-4 flex-shrink-0">
        <h2 class="text-sm font-black mb-2 c-text">{{ recruitment.title }}</h2>
        <div class="grid grid-cols-2 gap-x-4 gap-y-1 text-xs" :style="`color: var(--text-muted);`">
          <div v-if="recruitment.play_date">
            <span :style="`color: var(--text-faint);`">日程：</span>{{ formatPlayDate(recruitment.play_date) }}
          </div>
          <div v-if="recruitment.course_name">
            <span :style="`color: var(--text-faint);`">コース：</span>{{ recruitment.course_name }}
          </div>
          <div v-if="recruitment.prefecture">
            <span :style="`color: var(--text-faint);`">都道府県：</span>{{ recruitment.prefecture }}
          </div>
          <div v-if="recruitment.needed_players">
            <span :style="`color: var(--text-faint);`">募集人数：</span>{{ recruitment.needed_players }}人
          </div>
        </div>
      </div>

      <!-- メッセージ一覧 -->
      <div ref="messageContainer" class="flex-1 overflow-y-auto flex flex-col gap-3 pb-4">
        <div v-if="loading" class="flex justify-center py-10">
          <div class="w-8 h-8 border-2 rounded-full animate-spin"
            :style="`border-color: var(--border-card); border-top-color: #a3e635;`"></div>
        </div>

        <template v-else>
          <div v-for="message in messages" :key="message.id" class="flex gap-3"
            :class="message.user.id === currentUserId ? 'flex-row-reverse' : ''">
            <div class="w-8 h-8 rounded-full flex items-center justify-center text-sm flex-shrink-0"
              :style="`background: var(--avatar-bg); border: 1px solid var(--avatar-border);`">
              <img v-if="message.user?.image_url" :src="message.user.image_url" alt=""
                class="w-6 h-6 rounded-full object-cover flex-shrink-0 border border-[var(--avatar-border)]" />
              <span v-else>🏌️</span>
            </div>
            <div class="max-w-xs" :class="message.user.id === currentUserId ? 'items-end' : 'items-start'">
              <p class="text-xs mb-1" :style="`color: var(--text-faint);`"
                :class="message.user.id === currentUserId ? 'text-right' : ''">
                {{ message.user.name }}
              </p>
              <div class="px-4 py-2.5 rounded-2xl text-sm leading-relaxed"
                :class="message.user.id === currentUserId ? 'rounded-tr-sm' : 'rounded-tl-sm'"
                :style="message.user.id === currentUserId
                  ? 'background: linear-gradient(135deg, #166534, #14532d); color: #a3e635;'
                  : `background: var(--bg-chat-other); border: 1px solid var(--border-chat-other); color: var(--text);`">
                {{ message.body }}
              </div>
              <p class="text-xs mt-1" :style="`color: var(--text-faint);`"
                :class="message.user.id === currentUserId ? 'text-right' : ''">
                {{ formatTime(message.created_at) }}
              </p>
            </div>
          </div>
        </template>
      </div>

      <!-- 入力エリア -->
      <div class="flex items-center gap-3 px-4 py-3 mt-2 rounded-2xl flex-shrink-0"
        :style="`background: var(--bg-chat-input); border: 1px solid var(--border-chat-input);`">
        <input v-model="newMessage" @keydown.enter.prevent="sendMessage" type="text" placeholder="メッセージを入力..."
          class="flex-1 text-sm outline-none bg-transparent" :style="`color: var(--text);`" />
        <button @click="sendMessage" :disabled="!newMessage.trim()" class="btn-primary disabled:opacity-40"
          style="font-size: 0.8rem; padding: 0.5rem 1rem;">
          送信
        </button>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, nextTick } from 'vue'
import { useRoute } from 'vue-router'
import { createConsumer } from '@rails/actioncable'
import api from '../../lib/api.js'
import AppHeader from '../../components/AppHeader.vue'

const route = useRoute()
const messages = ref([])
const recruitment = ref(null)
const newMessage = ref('')
const loading = ref(true)
const messageContainer = ref(null)
const currentUserId = ref(null)

let consumer = null
let subscription = null

onMounted(async () => {
  try {
    const res = await api.get(`/api/v1/chats/${route.params.id}`)
    messages.value = res.data.messages
    recruitment.value = res.data.recruitment

    const token = localStorage.getItem('token')
    const payload = JSON.parse(atob(token.split('.')[1]))
    currentUserId.value = parseInt(payload.sub)

    const wsUrl = `${import.meta.env.VITE_WS_URL}/cable?token=${token}`
    consumer = createConsumer(wsUrl)
    subscription = consumer.subscriptions.create(
      { channel: 'ChatChannel', chat_id: route.params.id },
      {
        received(data) {
          messages.value.push(data)
          scrollToBottom()
        },
      }
    )

    scrollToBottom()
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
})

onUnmounted(() => {
  subscription?.unsubscribe()
  consumer?.disconnect()
})

const sendMessage = async () => {
  if (!newMessage.value.trim()) return
  subscription.perform('speak', { body: newMessage.value })
  newMessage.value = ''
}

const scrollToBottom = async () => {
  await nextTick()
  if (messageContainer.value) {
    messageContainer.value.scrollTop = messageContainer.value.scrollHeight
  }
}

const formatTime = (dateStr) => {
  if (!dateStr) return ''
  const d = new Date(dateStr)
  return `${d.getHours()}:${String(d.getMinutes()).padStart(2, '0')}`
}

const formatPlayDate = (dateStr) => {
  if (!dateStr) return ''
  const d = new Date(dateStr)
  return `${d.getFullYear()}年${d.getMonth() + 1}月${d.getDate()}日`
}
</script>
