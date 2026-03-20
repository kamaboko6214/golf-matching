<template>
  <div class="min-h-screen bg-gray-50">
    <AppHeader>
      <router-link to="/matches" class="text-sm text-green-300 hover:text-white transition">
        ← 一覧に戻る
      </router-link>
    </AppHeader>

    <main class="max-w-2xl mx-auto px-4 py-8">
      <h1 class="text-2xl font-black text-green-900 mb-6">募集を投稿する</h1>

      <form @submit.prevent="handleSubmit" class="bg-white rounded-xl shadow-sm border border-gray-100 p-6 flex flex-col gap-5">

        <div class="flex flex-col gap-1">
          <label class="text-xs font-bold text-gray-600 uppercase tracking-wide">タイトル</label>
          <InputText
            v-model="form.title"
            placeholder="例: 週末ゴルフ一緒にどうですか"
            class="w-full"
            required
          />
        </div>

        <div class="flex flex-col gap-1">
          <label class="text-xs font-bold text-gray-600 uppercase tracking-wide">詳細</label>
          <Textarea
            v-model="form.description"
            placeholder="募集の詳細を入力してください"
            rows="4"
            class="w-full resize-none"
          />
        </div>

        <div class="grid grid-cols-2 gap-4">
          <div class="flex flex-col gap-1">
            <label class="text-xs font-bold text-gray-600 uppercase tracking-wide">プレー日</label>
            <DatePicker
              v-model="form.play_date"
              dateFormat="yy/mm/dd"
              placeholder="日付を選択"
              showIcon
              class="w-full"
            />
          </div>
          <div class="flex flex-col gap-1">
            <label class="text-xs font-bold text-gray-600 uppercase tracking-wide">募集人数</label>
            <InputNumber
              v-model="form.needed_players"
              :min="1"
              :max="10"
              showButtons
              buttonLayout="horizontal"
              class="w-full"
            >
              <template #decrementbuttonicon>
                <span class="pi pi-minus" />
              </template>
              <template #incrementbuttonicon>
                <span class="pi pi-plus" />
              </template>
            </InputNumber>
          </div>
        </div>

        <div class="flex flex-col gap-1">
          <label class="text-xs font-bold text-gray-600 uppercase tracking-wide">コース名</label>
          <InputText
            v-model="form.course_name"
            placeholder="例: 東京ゴルフ倶楽部"
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

        <div v-if="errorMsg" class="bg-red-50 text-red-600 text-sm px-4 py-3 rounded-lg border border-red-100">
          {{ errorMsg }}
        </div>

        <button
          type="submit"
          :disabled="loading"
          class="bg-green-800 text-lime-400 font-black text-lg tracking-widest py-3 rounded-xl hover:bg-green-700 transition disabled:opacity-50"
        >
          <span v-if="loading">投稿中...</span>
          <span v-else>投稿する</span>
        </button>

      </form>
    </main>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import api from '../lib/api.js'
import InputText from 'primevue/inputtext'
import Textarea from 'primevue/textarea'
import DatePicker from 'primevue/datepicker'
import InputNumber from 'primevue/inputnumber'
import Select from 'primevue/select'
import AppHeader from '../components/AppHeader.vue'

const router = useRouter()
const loading = ref(false)
const errorMsg = ref('')

const form = ref({
  title: '',
  description: '',
  play_date: null,
  needed_players: 1,
  course_name: '',
  prefecture: '',
})

const prefectures = [
  '北海道', '青森県', '岩手県', '宮城県', '秋田県', '山形県', '福島県',
  '茨城県', '栃木県', '群馬県', '埼玉県', '千葉県', '東京都', '神奈川県',
  '新潟県', '富山県', '石川県', '福井県', '山梨県', '長野県', '岐阜県',
  '静岡県', '愛知県', '三重県', '滋賀県', '京都府', '大阪府', '兵庫県',
  '奈良県', '和歌山県', '鳥取県', '島根県', '岡山県', '広島県', '山口県',
  '徳島県', '香川県', '愛媛県', '高知県', '福岡県', '佐賀県', '長崎県',
  '熊本県', '大分県', '宮崎県', '鹿児島県', '沖縄県',
]

async function handleSubmit() {
  errorMsg.value = ''
  loading.value = true
  try {
    const payload = {
      ...form.value,
      play_date: form.value.play_date
        ? new Date(form.value.play_date).toISOString().split('T')[0]
        : null
    }
    await api.post('/api/v1/recruitments', { recruitment: payload })
    router.push('/matches')
  } catch (e) {
    errorMsg.value = e.response?.data?.errors?.join(', ') || 'エラーが発生しました'
  } finally {
    loading.value = false
  }
}
</script>