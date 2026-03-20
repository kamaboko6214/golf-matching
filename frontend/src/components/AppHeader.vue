<template>
  <header class="bg-green-900 text-white px-6 py-4 flex items-center justify-between">
    <div class="flex items-center gap-2">
      <span class="text-xl">⛳</span>
        <router-link
          to="/matches/"
          class="font-black text-lg tracking-widest"
        >
         GOLF<em class="not-italic text-lime-400">MATCH</em>
        </router-link>
    </div>
    <div class="flex items-center gap-4">
      <slot />
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