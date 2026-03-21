<template>
  <header class="bg-green-900 text-white px-6 py-4 flex items-center justify-between">
    <router-link to="/matches" class="flex items-center gap-2">
      <span class="text-xl">⛳</span>
      <span class="font-black text-lg tracking-widest"
        >GOLF<em class="not-italic text-lime-400">MATCH</em></span
      >
    </router-link>
    <div class="flex items-center gap-4">
      <slot />
      <router-link to="/mypage" class="text-sm text-green-300 hover:text-white transition">
        マイページ
      </router-link>
      <button @click="logout" class="text-sm text-green-300 hover:text-white transition">
        ログアウト
      </button>
    </div>
  </header>
</template>

<script setup>
  import { useRouter } from 'vue-router'

  const router = useRouter()

  function logout() {
    localStorage.removeItem('token')
    router.push('/login')
  }
</script>
