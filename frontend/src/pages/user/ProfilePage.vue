<template>
  <div class="page-bg">
    <AppHeader>
      <router-link to="/matches" class="text-xs font-bold transition" :style="`color: var(--text-muted);`">
        ← 一覧に戻る
      </router-link>
    </AppHeader>

    <main class="max-w-2xl mx-auto px-4 py-8">
      <h1 class="section-title mb-6" style="font-size: 1.8rem;">プロフィール編集</h1>

      <div v-if="loading" class="flex justify-center py-20">
        <div class="w-8 h-8 border-2 rounded-full animate-spin" :style="`border-color: var(--border-card); border-top-color: #a3e635;`"></div>
      </div>

      <form v-else @submit.prevent="handleSubmit" class="glass-card p-6 flex flex-col gap-5">
        <div class="flex flex-col items-center gap-3 pb-5" :style="`border-bottom: 1px solid var(--border-card);`">
          <div
            class="w-20 h-20 rounded-full flex items-center justify-center text-4xl"
            :style="`background: var(--avatar-bg); border: 2px solid var(--avatar-border);`"
          >
            🏌️
          </div>
          <p class="text-sm" :style="`color: var(--text-faint);`">{{ email }}</p>
        </div>

        <div class="flex flex-col gap-1.5">
          <label class="label-dark">名前</label>
          <InputText v-model="form.name" placeholder="例: 山田 太郎" class="w-full" />
        </div>

        <div class="grid grid-cols-2 gap-4">
          <div class="flex flex-col gap-1.5">
            <label class="label-dark">平均スコア</label>
            <InputNumber v-model="form.average_score" :min="50" :max="200" placeholder="90" class="w-full" />
          </div>
          <div class="flex flex-col gap-1.5">
            <label class="label-dark">都道府県</label>
            <Select v-model="form.prefecture" :options="prefectures" placeholder="選択してください" class="w-full" filter />
          </div>
        </div>

        <div class="flex flex-col gap-1.5">
          <label class="label-dark">自己紹介</label>
          <Textarea v-model="form.bio" placeholder="ゴルフ歴や得意なコース、一緒にラウンドしたい方へのメッセージなど" rows="4" class="w-full resize-none" />
        </div>

        <div v-if="errorMsg" class="text-sm px-4 py-3 rounded-lg bg-red-100 text-red-700 border border-red-200 dark:bg-red-950/30 dark:text-red-400 dark:border-red-800/30">
          {{ errorMsg }}
        </div>
        <div v-if="successMsg" class="text-sm px-4 py-3 rounded-lg bg-green-100 text-green-700 border border-green-200 dark:bg-lime-900/20 dark:text-lime-400 dark:border-lime-700/30">
          {{ successMsg }}
        </div>

        <button type="submit" :disabled="saving" class="btn-primary w-full text-center">
          <span v-if="saving" class="flex items-center justify-center gap-2">
            <span class="w-4 h-4 border-2 border-green-900/30 border-t-green-900 rounded-full animate-spin"></span>
            保存中...
          </span>
          <span v-else>保存する</span>
        </button>
      </form>
    </main>
  </div>
</template>

<script setup>
  import { ref, onMounted } from 'vue'
  import api from '../../lib/api.js'
  import AppHeader from '../../components/AppHeader.vue'
  import InputText from 'primevue/inputtext'
  import InputNumber from 'primevue/inputnumber'
  import Select from 'primevue/select'
  import Textarea from 'primevue/textarea'
  import { prefectures } from '../../constants/prefectures.js'

  const loading = ref(true)
  const saving = ref(false)
  const errorMsg = ref('')
  const successMsg = ref('')
  const email = ref('')
  const isNew = ref(false)

  const form = ref({
    name: '',
    average_score: null,
    prefecture: '',
    bio: '',
  })

  onMounted(async () => {
    try {
      const res = await api.get('/api/v1/profile')
      if (res.data) {
        form.value = {
          name: res.data.name || '',
          average_score: res.data.average_score,
          prefecture: res.data.prefecture || '',
          bio: res.data.bio || '',
        }
        email.value = res.data.email
      } else {
        isNew.value = true
      }
    } catch (e) {
      console.error(e)
    } finally {
      loading.value = false
    }
  })

  async function handleSubmit() {
    saving.value = true
    errorMsg.value = ''
    successMsg.value = ''
    try {
      if (isNew.value) {
        await api.post('/api/v1/profile', { profile: form.value })
        isNew.value = false
      } else {
        await api.patch('/api/v1/profile', { profile: form.value })
      }
      successMsg.value = 'プロフィールを保存しました！'
    } catch (e) {
      errorMsg.value = e.response?.data?.errors?.join(', ') || 'エラーが発生しました'
    } finally {
      saving.value = false
    }
  }
</script>
