<template>
  <div class="min-h-screen bg-gray-50">
    <AppHeader>
      <router-link to="/matches" class="text-sm text-green-300 hover:text-white transition">
        ← 一覧に戻る
      </router-link>
    </AppHeader>

    <main class="max-w-2xl mx-auto px-4 py-8">
      <h1 class="text-2xl font-black text-green-900 mb-6">プロフィール編集</h1>

      <div v-if="loading" class="flex justify-center py-20">
        <div
          class="w-8 h-8 border-4 border-green-600 border-t-transparent rounded-full animate-spin"
        ></div>
      </div>

      <form
        v-else
        @submit.prevent="handleSubmit"
        class="bg-white rounded-xl shadow-sm border border-gray-100 p-6 flex flex-col gap-5"
      >
        <div class="flex flex-col items-center gap-3 pb-4 border-b border-gray-50">
          <div
            class="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center text-4xl"
          >
            🏌️
          </div>
          <p class="text-sm text-gray-400">{{ email }}</p>
        </div>

        <div class="flex flex-col gap-1">
          <label class="text-xs font-bold text-gray-600 uppercase tracking-wide">名前</label>
          <InputText v-model="form.name" placeholder="例: 山田 太郎" class="w-full" />
        </div>

        <div class="grid grid-cols-2 gap-4">
          <div class="flex flex-col gap-1">
            <label class="text-xs font-bold text-gray-600 uppercase tracking-wide">ハンデ</label>
            <InputNumber
              v-model="form.handicap"
              :min="0"
              :max="54"
              placeholder="18"
              class="w-full"
            />
          </div>
          <div class="flex flex-col gap-1">
            <label class="text-xs font-bold text-gray-600 uppercase tracking-wide">都道府県</label>
            <Select
              v-model="form.prefecture"
              :options="prefectures"
              placeholder="選択してください"
              class="w-full"
              filter
            />
          </div>
        </div>

        <div class="flex flex-col gap-1">
          <label class="text-xs font-bold text-gray-600 uppercase tracking-wide">自己紹介</label>
          <Textarea
            v-model="form.bio"
            placeholder="ゴルフ歴や得意なコース、一緒にラウンドしたい方へのメッセージなど"
            rows="4"
            class="w-full resize-none"
          />
        </div>

        <div
          v-if="errorMsg"
          class="bg-red-50 text-red-600 text-sm px-4 py-3 rounded-lg border border-red-100"
        >
          {{ errorMsg }}
        </div>
        <div
          v-if="successMsg"
          class="bg-green-50 text-green-700 text-sm px-4 py-3 rounded-lg border border-green-100"
        >
          {{ successMsg }}
        </div>

        <button
          type="submit"
          :disabled="loading"
          class="bg-green-800 text-lime-400 font-black text-lg tracking-widest py-3 rounded-xl hover:bg-green-700 transition disabled:opacity-50"
        >
          <span v-if="saving">保存中...</span>
          <span v-else>保存する</span>
        </button>
      </form>
    </main>
  </div>
</template>

<script setup>
  import { ref, onMounted } from 'vue'
  import api from '../lib/api.js'
  import AppHeader from '../components/AppHeader.vue'
  import InputText from 'primevue/inputtext'
  import InputNumber from 'primevue/inputnumber'
  import Select from 'primevue/select'
  import Textarea from 'primevue/textarea'

  const loading = ref(true)
  const saving = ref(false)
  const errorMsg = ref('')
  const successMsg = ref('')
  const email = ref('')
  const isNew = ref(false)

  const form = ref({
    name: '',
    handicap: null,
    prefecture: '',
    bio: '',
  })

  const prefectures = [
    '北海道',
    '青森県',
    '岩手県',
    '宮城県',
    '秋田県',
    '山形県',
    '福島県',
    '茨城県',
    '栃木県',
    '群馬県',
    '埼玉県',
    '千葉県',
    '東京都',
    '神奈川県',
    '新潟県',
    '富山県',
    '石川県',
    '福井県',
    '山梨県',
    '長野県',
    '岐阜県',
    '静岡県',
    '愛知県',
    '三重県',
    '滋賀県',
    '京都府',
    '大阪府',
    '兵庫県',
    '奈良県',
    '和歌山県',
    '鳥取県',
    '島根県',
    '岡山県',
    '広島県',
    '山口県',
    '徳島県',
    '香川県',
    '愛媛県',
    '高知県',
    '福岡県',
    '佐賀県',
    '長崎県',
    '熊本県',
    '大分県',
    '宮崎県',
    '鹿児島県',
    '沖縄県',
  ]

  onMounted(async () => {
    try {
      const res = await api.get('/api/v1/profile')
      if (res.data) {
        form.value = {
          name: res.data.name || '',
          handicap: res.data.handicap,
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
