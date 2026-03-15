<template>
  <div>
    <router-view />
  </div>
</template>

<script setup>
import api from './lib/api.js'

async function testApi() {
  try {
    const res = await api.get('/api/v1/recruitments')
    console.log(res.data)
    alert(JSON.stringify(res.data))
  } catch (e) {
    alert('エラー: ' + e.response?.status + ' ' + JSON.stringify(e.response?.data))
  }
}
</script>