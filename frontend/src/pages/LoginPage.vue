<template>
  <div class="min-h-screen bg-[#0a1f0e] flex items-center justify-center relative overflow-hidden">
    <!-- bg pattern -->
    <div
      class="absolute inset-0 pointer-events-none"
      style="background-image: repeating-linear-gradient(45deg, transparent, transparent 60px, rgba(180,230,100,0.03) 60px, rgba(180,230,100,0.03) 61px)"
    ></div>

    <div class="flex w-[min(960px,95vw)] min-h-[580px] rounded-2xl overflow-hidden shadow-[0_32px_80px_rgba(0,0,0,0.6)] relative z-10">

      <!-- Left panel -->
      <div class="hidden md:flex flex-[1.1] flex-col gap-9 p-12 bg-gradient-to-br from-[#133a1a] via-[#0d2b12] to-[#071a09] border-r border-[rgba(180,230,100,0.12)]">
        <div class="flex items-center gap-2.5">
          <span class="text-[22px]">⛳</span>
          <span class="font-['Bebas_Neue'] text-[22px] tracking-[0.12em] text-[#c8e87a]">
            GOLF<em class="not-italic text-white">MATCH</em>
          </span>
        </div>

        <div>
          <h1 class="font-['Bebas_Neue'] text-[clamp(36px,4vw,52px)] leading-[1.1] text-white tracking-[0.04em]">
            理想のゴルフ<br>パートナーと<br><span class="text-[#c8e87a]">出会おう。</span>
          </h1>
          <p class="mt-4 text-white/55 text-sm leading-[1.8]">
            スコアも人柄も合う仲間が、<br>すぐそこにいる。
          </p>
        </div>

        <div class="flex items-center gap-5 mt-auto p-5 bg-white/[0.04] rounded-xl border border-[rgba(200,232,122,0.12)]">
          <div class="flex flex-col items-center flex-1">
            <span class="font-['Bebas_Neue'] text-[26px] text-[#c8e87a] tracking-[0.06em]">2,400+</span>
            <span class="text-[11px] text-white/45 mt-0.5">登録ゴルファー</span>
          </div>
          <div class="w-px h-9 bg-white/10"></div>
          <div class="flex flex-col items-center flex-1">
            <span class="font-['Bebas_Neue'] text-[26px] text-[#c8e87a] tracking-[0.06em]">180+</span>
            <span class="text-[11px] text-white/45 mt-0.5">対応コース</span>
          </div>
          <div class="w-px h-9 bg-white/10"></div>
          <div class="flex flex-col items-center flex-1">
            <span class="font-['Bebas_Neue'] text-[26px] text-[#c8e87a] tracking-[0.06em]">94%</span>
            <span class="text-[11px] text-white/45 mt-0.5">マッチング満足度</span>
          </div>
        </div>
      </div>

      <!-- Right panel -->
      <div class="flex-1 bg-[#f5f7f2] px-7 py-9 md:p-12 flex flex-col">
        <div class="flex bg-[#e8ede3] rounded-[10px] p-1 mb-8">
          <button
            class="flex-1 py-2.5 rounded-[7px] text-sm font-bold transition-all duration-200"
            :class="mode === 'login'
              ? 'bg-white text-[#1a3d1f] shadow-[0_2px_8px_rgba(0,0,0,0.1)]'
              : 'bg-transparent text-[#6b7c61]'"
            @click="mode = 'login'"
          >ログイン</button>
          <button
            class="flex-1 py-2.5 rounded-[7px] text-sm font-bold transition-all duration-200"
            :class="mode === 'register'
              ? 'bg-white text-[#1a3d1f] shadow-[0_2px_8px_rgba(0,0,0,0.1)]'
              : 'bg-transparent text-[#6b7c61]'"
            @click="mode = 'register'"
          >新規登録</button>
        </div>

        <form class="flex flex-col gap-[18px]" @submit.prevent="handleSubmit">
          <div class="flex flex-col gap-1.5">
            <label class="text-xs font-bold text-[#3a4f35] tracking-[0.05em] uppercase">メールアドレス</label>
            <input
              v-model="email"
              type="email"
              placeholder="your@email.com"
              autocomplete="email"
              class="px-4 py-3 border-[1.5px] border-[#d4dece] rounded-lg text-[15px] text-[#1a2e16] bg-white outline-none transition placeholder:text-[#b0bca8] focus:border-[#4d9e3f] focus:ring-[3px] focus:ring-[rgba(77,158,63,0.12)]"
            />
          </div>

          <div class="flex flex-col gap-1.5">
            <label class="text-xs font-bold text-[#3a4f35] tracking-[0.05em] uppercase">パスワード</label>
            <input
              v-model="password"
              type="password"
              placeholder="••••••••"
              autocomplete="current-password"
              class="px-4 py-3 border-[1.5px] border-[#d4dece] rounded-lg text-[15px] text-[#1a2e16] bg-white outline-none transition placeholder:text-[#b0bca8] focus:border-[#4d9e3f] focus:ring-[3px] focus:ring-[rgba(77,158,63,0.12)]"
            />
          </div>

          <div v-if="mode === 'register'" class="flex flex-col gap-1.5">
            <label class="text-xs font-bold text-[#3a4f35] tracking-[0.05em] uppercase">パスワード（確認）</label>
            <input
              v-model="passwordConfirm"
              type="password"
              placeholder="••••••••"
              autocomplete="new-password"
              class="px-4 py-3 border-[1.5px] border-[#d4dece] rounded-lg text-[15px] text-[#1a2e16] bg-white outline-none transition placeholder:text-[#b0bca8] focus:border-[#4d9e3f] focus:ring-[3px] focus:ring-[rgba(77,158,63,0.12)]"
            />
          </div>

          <div v-if="errorMsg" class="bg-[#fee] text-[#c0392b] text-[13px] px-3.5 py-2.5 rounded-lg border border-[#f5c6cb]">
            {{ errorMsg }}
          </div>
          <div v-if="successMsg" class="bg-[#edfbee] text-[#27ae60] text-[13px] px-3.5 py-2.5 rounded-lg border border-[#b2dfdb]">
            {{ successMsg }}
          </div>

          <button
            type="submit"
            :disabled="loading"
            class="mt-1.5 py-3.5 bg-[#1f5c28] text-[#c8e87a] rounded-[10px] font-['Bebas_Neue'] text-lg tracking-[0.1em] transition-all flex items-center justify-center gap-2 hover:enabled:bg-[#246b2f] hover:enabled:-translate-y-px disabled:opacity-60 disabled:cursor-not-allowed"
          >
            <span v-if="loading" class="w-[18px] h-[18px] border-2 border-[rgba(200,232,122,0.3)] border-t-[#c8e87a] rounded-full animate-spin"></span>
            <span v-else>{{ mode === 'login' ? 'ログイン' : 'アカウント作成' }}</span>
          </button>
        </form>

        <p v-if="mode === 'login'" class="mt-5 text-center text-[13px] text-[#7a8f73]">
          アカウントをお持ちでない方は
          <a href="#" class="text-[#2d7a35] font-bold no-underline hover:underline" @click.prevent="mode = 'register'">新規登録</a>
        </p>
        <p v-else class="mt-5 text-center text-[13px] text-[#7a8f73]">
          すでにアカウントをお持ちの方は
          <a href="#" class="text-[#2d7a35] font-bold no-underline hover:underline" @click.prevent="mode = 'login'">ログイン</a>
        </p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import api from '../lib/api.js'
import { useRouter } from 'vue-router'

const router = useRouter()
const mode = ref('login')
const email = ref('')
const password = ref('')
const passwordConfirm = ref('')
const loading = ref(false)
const errorMsg = ref('')
const successMsg = ref('')

async function handleSubmit() {
  errorMsg.value = ''
  successMsg.value = ''

  if (mode.value === 'register' && password.value !== passwordConfirm.value) {
    errorMsg.value = 'パスワードが一致しません'
    return
  }

  loading.value = true
  try {
    if (mode.value === 'login') {
      const res = await api.post('/api/v1/users/sign_in', {
        user: { email: email.value, password: password.value }
      })
      const token = res.headers['authorization']?.replace('Bearer ', '')
      if (token) localStorage.setItem('token', token)
      router.push('/matches')
    } else {
      await api.post('/api/v1/users/sign_up', {
        user: { email: email.value, password: password.value }
      })
      successMsg.value = '登録完了！ログインしてください'
      mode.value = 'login'
    }
  } catch (e) {
    errorMsg.value = e.response?.data?.errors?.join(', ') || 'エラーが発生しました'
  } finally {
    loading.value = false
  }
}
</script>

<style>
@import url('https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Noto+Sans+JP:wght@400;700&display=swap');
</style>