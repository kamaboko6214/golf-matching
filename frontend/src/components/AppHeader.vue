<template>
  <header class="sticky top-0 z-50" :style="`background: var(--bg-header); backdrop-filter: blur(16px); border-bottom: 1px solid var(--border-header);`">
    <div class="max-w-6xl mx-auto px-4 h-14 flex items-center justify-between gap-4">

      <router-link to="/matches" class="flex items-center gap-2.5 flex-shrink-0">
        <span class="text-xl leading-none">⛳</span>
        <span style="font-family: 'Bebas Neue', sans-serif; font-size: 1.2rem; letter-spacing: 0.12em; color: #a3e635;">
          GOLF<em class="not-italic" :style="`color: var(--text-title);`">MATCH</em>
        </span>
      </router-link>

      <div class="flex items-center gap-1 sm:gap-3">
        <slot />

        <router-link
          to="/mypage"
          class="text-xs font-bold transition px-2.5 py-1.5 rounded-lg"
          :style="`color: var(--text-muted);`"
          :class="'hover:brightness-125'"
        >
          マイページ
        </router-link>

        <!-- テーマトグル -->
        <button
          @click="toggle"
          class="w-8 h-8 flex items-center justify-center rounded-lg transition text-base"
          :style="`color: var(--text-muted);`"
          :title="isDark ? 'ライトモードに切替' : 'ナイトモードに切替'"
        >
          {{ isDark ? '☀️' : '🌙' }}
        </button>

        <!-- 通知ベル -->
        <div class="relative">
          <button
            @click="toggleNotifications"
            class="relative w-8 h-8 flex items-center justify-center rounded-lg transition text-base"
            :style="`color: var(--text-muted);`"
          >
            🔔
            <span
              v-if="unreadCount > 0"
              class="absolute -top-0.5 -right-0.5 bg-red-500 text-white text-[9px] rounded-full w-3.5 h-3.5 flex items-center justify-center font-black"
            >
              {{ unreadCount > 9 ? '9+' : unreadCount }}
            </span>
          </button>

          <!-- 通知ドロップダウン -->
          <div
            v-if="showNotifications"
            class="absolute right-0 top-10 w-80 rounded-xl overflow-hidden z-50"
            :style="`background: var(--bg-notification); border: 1px solid var(--border-notification); box-shadow: 0 20px 60px rgba(0,0,0,0.2);`"
          >
            <div class="flex items-center justify-between px-4 py-3" :style="`border-bottom: 1px solid var(--border-card);`">
              <p style="font-family: 'Bebas Neue', sans-serif; font-size: 1rem; letter-spacing: 0.08em;" class="c-text">通知</p>
              <button
                v-if="unreadCount > 0"
                @click="markAllRead"
                class="text-xs font-bold transition"
                :style="`color: var(--text-label);`"
              >
                すべて既読
              </button>
            </div>

            <div class="max-h-72 overflow-y-auto">
              <div v-if="notifications.length === 0" class="text-center py-8 text-sm" :style="`color: var(--text-faint);`">
                通知はありません
              </div>
              <div
                v-for="n in notifications"
                :key="n.id"
                @click="readNotification(n)"
                class="px-4 py-3 cursor-pointer transition"
                :style="`border-bottom: 1px solid var(--border-card); background: ${!n.read ? 'var(--notif-unread-bg)' : 'transparent'};`"
              >
                <div class="flex items-start gap-2.5">
                  <span class="text-xs mt-0.5">{{ !n.read ? '🟢' : '⚫' }}</span>
                  <div>
                    <p class="text-sm font-bold c-text">{{ n.title }}</p>
                    <p class="text-xs mt-0.5 leading-relaxed" :style="`color: var(--text-muted);`">{{ n.body }}</p>
                    <p class="text-xs mt-1" :style="`color: var(--text-faint);`">{{ formatTime(n.created_at) }}</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <button
          @click="logout"
          class="text-xs font-bold transition px-2.5 py-1.5 rounded-lg"
          :style="`color: var(--text-faint);`"
        >
          <span class="hidden sm:inline">ログアウト</span>
          <span class="sm:hidden">退出</span>
        </button>
      </div>
    </div>
  </header>

  <div
    v-if="showNotifications"
    class="fixed inset-0 z-40"
    @click="showNotifications = false"
  />
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import api from '../lib/api.js'
import { useTheme } from '../lib/useTheme.js'

const router = useRouter()
const { isDark, toggle } = useTheme()
const notifications = ref([])
const unreadCount = ref(0)
const showNotifications = ref(false)

onMounted(() => {
  fetchNotifications()
  setInterval(fetchNotifications, 30000)
})

const fetchNotifications = async () => {
  try {
    const res = await api.get('/api/v1/notifications')
    notifications.value = res.data.notifications
    unreadCount.value = res.data.unread_count
  } catch (e) {
    console.error(e)
  }
}

const toggleNotifications = () => {
  showNotifications.value = !showNotifications.value
  if (showNotifications.value) fetchNotifications()
}

const readNotification = async (notification) => {
  if (!notification.read) {
    await api.patch(`/api/v1/notifications/${notification.id}`)
    notification.read = true
    unreadCount.value = Math.max(0, unreadCount.value - 1)
  }
  showNotifications.value = false
  if (notification.link) {
    router.push(notification.link)
  }
}

const markAllRead = async () => {
  await api.patch('/api/v1/notifications/mark_all_read')
  notifications.value.forEach(n => n.read = true)
  unreadCount.value = 0
}

const formatTime = (dateStr) => {
  if (!dateStr) return ''
  const d = new Date(dateStr)
  const now = new Date()
  const diff = now - d
  if (diff < 60000) return 'たった今'
  if (diff < 3600000) return `${Math.floor(diff / 60000)}分前`
  if (diff < 86400000) return `${Math.floor(diff / 3600000)}時間前`
  return `${d.getMonth() + 1}/${d.getDate()}`
}

const logout = () => {
  localStorage.removeItem('token')
  router.push('/login')
}
</script>
