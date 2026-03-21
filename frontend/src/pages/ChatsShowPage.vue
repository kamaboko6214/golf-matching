<template>
  <div class="min-h-screen bg-gray-50 flex flex-col">
    <AppHeader>
      <router-link to="/chats" class="text-sm text-green-300 hover:text-white transition">
        ← チャット一覧
      </router-link>
    </AppHeader>

    <main class="flex-1 max-w-2xl w-full mx-auto px-4 py-4 flex flex-col">
      <!-- メッセージ一覧 -->
      <div ref="messageContainer" class="flex-1 overflow-y-auto flex flex-col gap-3 pb-4">
        <div v-if="loading" class="flex justify-center py-10">
          <div
            class="w-8 h-8 border-4 border-green-600 border-t-transparent rounded-full animate-spin"
          ></div>
        </div>

        <template v-else>
          <div
            v-for="message in messages"
            :key="message.id"
            class="flex gap-3"
            :class="message.user.id === currentUserId ? 'flex-row-reverse' : ''"
          >
            <div
              class="w-8 h-8 rounded-full bg-green-100 flex items-center justify-center text-sm flex-shrink-0"
            >
              🏌️
            </div>
            <div
              class="max-w-xs"
              :class="message.user.id === currentUserId ? 'items-end' : 'items-start'"
            >
              <p
                class="text-xs text-gray-400 mb-1"
                :class="message.user.id === currentUserId ? 'text-right' : ''"
              >
                {{ message.user.name }}
              </p>
              <div
                class="px-4 py-2 rounded-2xl text-sm leading-relaxed"
                :class="
                  message.user.id === currentUserId
                    ? 'bg-green-800 text-lime-300 rounded-tr-sm'
                    : 'bg-white border border-gray-100 text-gray-800 rounded-tl-sm'
                "
              >
                {{ message.body }}
              </div>
              <p
                class="text-xs text-gray-300 mt-1"
                :class="message.user.id === currentUserId ? 'text-right' : ''"
              >
                {{ formatTime(message.created_at) }}
              </p>
            </div>
          </div>
        </template>
      </div>

      <!-- 入力エリア -->
      <div
        class="bg-white border border-gray-200 rounded-2xl flex items-center gap-3 px-4 py-3 mt-4"
      >
        <input
          v-model="newMessage"
          @keydown.enter.prevent="sendMessage"
          type="text"
          placeholder="メッセージを入力..."
          class="flex-1 text-sm outline-none text-gray-800 placeholder-gray-300"
        />
        <button
          @click="sendMessage"
          :disabled="!newMessage.trim()"
          class="bg-green-800 text-lime-400 rounded-xl px-4 py-2 text-sm font-bold hover:bg-green-700 transition disabled:opacity-40"
        >
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
  import api from '../lib/api.js'
  import AppHeader from '../components/AppHeader.vue'

  const route = useRoute()
  const messages = ref([])
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

      // 現在のユーザーIDを取得
      const token = localStorage.getItem('token')
      const payload = JSON.parse(atob(token.split('.')[1]))
      currentUserId.value = parseInt(payload.sub)

      // Action Cableに接続
      const wsUrl = `ws://localhost:3000/cable?token=${token}`
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

  async function sendMessage() {
    if (!newMessage.value.trim()) return
    subscription.perform('speak', { body: newMessage.value })
    newMessage.value = ''
  }

  async function scrollToBottom() {
    await nextTick()
    if (messageContainer.value) {
      messageContainer.value.scrollTop = messageContainer.value.scrollHeight
    }
  }

  function formatTime(dateStr) {
    if (!dateStr) return ''
    const d = new Date(dateStr)
    return `${d.getHours()}:${String(d.getMinutes()).padStart(2, '0')}`
  }
</script>
