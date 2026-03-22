<template>
  <div class="page-bg">
    <AppHeader>
      <router-link :to="`/matches/${route.params.id}`" class="text-xs font-bold transition" :style="`color: var(--text-muted);`">
        ← 詳細に戻る
      </router-link>
    </AppHeader>

    <main class="max-w-2xl mx-auto px-4 py-8">
      <h1 class="section-title mb-6" style="font-size: 1.8rem;">募集を編集する</h1>

      <div v-if="loading" class="flex justify-center py-20">
        <div class="w-8 h-8 border-2 rounded-full animate-spin" :style="`border-color: var(--border-card); border-top-color: #a3e635;`"></div>
      </div>

      <form v-else @submit.prevent="handleSubmit" class="glass-card p-6 flex flex-col gap-5">

        <div class="flex flex-col gap-1.5">
          <label class="label-dark">タイトル</label>
          <InputText v-model="form.title" placeholder="例: 週末ゴルフ一緒にどうですか" class="w-full" required />
        </div>

        <div class="flex flex-col gap-1.5">
          <label class="label-dark">詳細</label>
          <Textarea v-model="form.description" placeholder="募集の詳細を入力してください" rows="4" class="w-full resize-none" />
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div class="flex flex-col gap-1.5">
            <label class="label-dark">プレー日</label>
            <DatePicker v-model="form.play_date" dateFormat="yy/mm/dd" placeholder="日付を選択" showIcon class="w-full" />
          </div>
          <div class="flex flex-col gap-1.5">
            <label class="label-dark">募集人数</label>
            <InputNumber
              v-model="form.needed_players"
              :min="1"
              :max="10"
              showButtons
              buttonLayout="horizontal"
              class="w-full"
              style="width: 100%;"
              :pt="{ input: { style: 'min-width: 0; flex: 1;' } }"
            >
              <template #decrementbuttonicon><span class="pi pi-minus" /></template>
              <template #incrementbuttonicon><span class="pi pi-plus" /></template>
            </InputNumber>
          </div>
        </div>

        <div class="flex flex-col gap-1.5">
          <label class="label-dark">コース名</label>
          <InputText v-model="form.course_name" placeholder="例: 東京ゴルフ倶楽部" class="w-full" />
        </div>

        <div class="flex flex-col gap-1.5">
          <label class="label-dark">コース画像</label>
          <div
            class="rounded-xl p-6 text-center cursor-pointer transition"
            :style="`border: 2px dashed var(--border-drop); background: var(--bg-drop);`"
            @click="$refs.fileInput.click()"
            @dragover.prevent
            @drop.prevent="onDrop"
          >
            <div v-if="imagePreview">
              <img :src="imagePreview" class="max-h-40 mx-auto rounded-lg object-cover" />
              <p class="text-xs mt-2" :style="`color: var(--text-faint);`">クリックして変更</p>
            </div>
            <div v-else>
              <p class="text-3xl mb-2">🏌️</p>
              <p class="text-sm" :style="`color: var(--text-muted);`">クリックまたはドラッグで画像をアップロード</p>
              <p class="text-xs mt-1" :style="`color: var(--text-faint);`">JPG, PNG, GIF（最大5MB）</p>
            </div>
          </div>
          <input ref="fileInput" type="file" accept="image/*" class="hidden" @change="onFileChange" />
        </div>

        <div class="flex flex-col gap-1.5">
          <label class="label-dark">都道府県</label>
          <Select v-model="form.prefecture" :options="prefectures" placeholder="選択してください" class="w-full" filter />
        </div>

        <div v-if="errorMsg" class="text-sm px-4 py-3 rounded-lg bg-red-100 text-red-700 border border-red-200 dark:bg-red-950/30 dark:text-red-400 dark:border-red-800/30">
          {{ errorMsg }}
        </div>

        <button type="submit" :disabled="submitting" class="btn-primary w-full text-center">
          <span v-if="submitting" class="flex items-center justify-center gap-2">
            <span class="w-4 h-4 border-2 border-green-900/30 border-t-green-900 rounded-full animate-spin"></span>
            更新中...
          </span>
          <span v-else>更新する</span>
        </button>

      </form>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import api from '../../lib/api.js'
import InputText from 'primevue/inputtext'
import Textarea from 'primevue/textarea'
import DatePicker from 'primevue/datepicker'
import InputNumber from 'primevue/inputnumber'
import Select from 'primevue/select'
import AppHeader from '../../components/AppHeader.vue'
import { prefectures } from '../../constants/prefectures.js'

const route = useRoute()
const router = useRouter()
const loading = ref(true)
const submitting = ref(false)
const errorMsg = ref('')
const imagePreview = ref(null)
const imageFile = ref(null)

const form = ref({
  title: '',
  description: '',
  play_date: null,
  needed_players: 1,
  course_name: '',
  prefecture: '',
})

onMounted(async () => {
  try {
    const res = await api.get(`/api/v1/recruitments/${route.params.id}/edit`)
    const data = res.data
    form.value = {
      title: data.title,
      description: data.description,
      play_date: data.play_date ? new Date(data.play_date) : null,
      needed_players: data.needed_players,
      course_name: data.course_name,
      prefecture: data.prefecture,
    }
    if (data.image_url) {
      imagePreview.value = data.image_url
    }
  } catch (e) {
    if (e.response?.status === 403) {
      router.push(`/matches/${route.params.id}`)
    } else {
      errorMsg.value = 'データの取得に失敗しました'
    }
  } finally {
    loading.value = false
  }
})

const handleSubmit = async () => {
  errorMsg.value = ''
  submitting.value = true
  try {
    const formData = new FormData()
    formData.append('recruitment[title]', form.value.title)
    formData.append('recruitment[description]', form.value.description)
    formData.append('recruitment[play_date]', form.value.play_date
      ? new Date(form.value.play_date).toISOString().split('T')[0]
      : '')
    formData.append('recruitment[needed_players]', form.value.needed_players)
    formData.append('recruitment[course_name]', form.value.course_name)
    formData.append('recruitment[prefecture]', form.value.prefecture)
    if (imageFile.value) {
      formData.append('recruitment[image]', imageFile.value)
    }

    await api.patch(`/api/v1/recruitments/${route.params.id}`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
    router.push(`/matches/${route.params.id}`)
  } catch (e) {
    errorMsg.value = e.response?.data?.errors?.join(', ') || 'エラーが発生しました'
  } finally {
    submitting.value = false
  }
}

const onFileChange = (e) => {
  const file = e.target.files[0]
  if (!file) return
  imageFile.value = file
  imagePreview.value = URL.createObjectURL(file)
}

const onDrop = (e) => {
  const file = e.dataTransfer.files[0]
  if (!file) return
  imageFile.value = file
  imagePreview.value = URL.createObjectURL(file)
}
</script>
