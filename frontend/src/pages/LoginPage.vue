<template>
    <div class="auth-root">
      <div class="bg-pattern"></div>
  
      <div class="auth-container">
        <!-- Left panel -->
        <div class="left-panel">
          <div class="logo">
            <span class="logo-icon">⛳</span>
            <span class="logo-text">GOLF<em>MATCH</em></span>
          </div>
          <div class="hero-text">
            <h1>理想のゴルフ<br>パートナーと<br><span class="accent">出会おう。</span></h1>
            <p>スコアも人柄も合う仲間が、<br>すぐそこにいる。</p>
          </div>
          <div class="course-stat">
            <div class="stat">
              <span class="stat-num">2,400+</span>
              <span class="stat-label">登録ゴルファー</span>
            </div>
            <div class="stat-divider"></div>
            <div class="stat">
              <span class="stat-num">180+</span>
              <span class="stat-label">対応コース</span>
            </div>
            <div class="stat-divider"></div>
            <div class="stat">
              <span class="stat-num">94%</span>
              <span class="stat-label">マッチング満足度</span>
            </div>
          </div>
        </div>
  
        <!-- Right panel: form -->
        <div class="right-panel">
          <div class="tab-row">
            <button
              class="tab"
              :class="{ active: mode === 'login' }"
              @click="mode = 'login'"
            >ログイン</button>
            <button
              class="tab"
              :class="{ active: mode === 'register' }"
              @click="mode = 'register'"
            >新規登録</button>
          </div>
  
          <form class="auth-form" @submit.prevent="handleSubmit">
            <div class="field">
              <label>メールアドレス</label>
              <input
                v-model="email"
                type="email"
                placeholder="your@email.com"
                autocomplete="email"
              />
            </div>
            <div class="field">
              <label>パスワード</label>
              <input
                v-model="password"
                type="password"
                placeholder="••••••••"
                autocomplete="current-password"
              />
            </div>
            <div v-if="mode === 'register'" class="field">
              <label>パスワード（確認）</label>
              <input
                v-model="passwordConfirm"
                type="password"
                placeholder="••••••••"
                autocomplete="new-password"
              />
            </div>
  
            <div v-if="errorMsg" class="error-msg">{{ errorMsg }}</div>
            <div v-if="successMsg" class="success-msg">{{ successMsg }}</div>
  
            <button type="submit" class="submit-btn" :disabled="loading">
              <span v-if="loading" class="spinner"></span>
              <span v-else>{{ mode === 'login' ? 'ログイン' : 'アカウント作成' }}</span>
            </button>
          </form>
  
          <p class="switch-hint" v-if="mode === 'login'">
            アカウントをお持ちでない方は
            <a href="#" @click.prevent="mode = 'register'">新規登録</a>
          </p>
          <p class="switch-hint" v-else>
            すでにアカウントをお持ちの方は
            <a href="#" @click.prevent="mode = 'login'">ログイン</a>
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
  
  <style scoped>
  @import url('https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Noto+Sans+JP:wght@400;700&display=swap');
  
  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
  
  .auth-root {
    min-height: 100vh;
    background: #0a1f0e;
    display: flex;
    align-items: center;
    justify-content: center;
    font-family: 'Noto Sans JP', sans-serif;
    position: relative;
    overflow: hidden;
  }
  
  .bg-pattern {
    position: absolute;
    inset: 0;
    background-image:
      repeating-linear-gradient(
        45deg,
        transparent,
        transparent 60px,
        rgba(180,230,100,0.03) 60px,
        rgba(180,230,100,0.03) 61px
      );
    pointer-events: none;
  }
  
  .auth-container {
    display: flex;
    width: min(960px, 95vw);
    min-height: 580px;
    border-radius: 20px;
    overflow: hidden;
    box-shadow: 0 32px 80px rgba(0,0,0,0.6);
    position: relative;
    z-index: 1;
  }
  
  /* Left panel */
  .left-panel {
    flex: 1.1;
    background: linear-gradient(155deg, #133a1a 0%, #0d2b12 60%, #071a09 100%);
    padding: 48px 44px;
    display: flex;
    flex-direction: column;
    gap: 36px;
    border-right: 1px solid rgba(180,230,100,0.12);
  }
  
  .logo {
    display: flex;
    align-items: center;
    gap: 10px;
  }
  .logo-icon { font-size: 22px; }
  .logo-text {
    font-family: 'Bebas Neue', sans-serif;
    font-size: 22px;
    letter-spacing: 0.12em;
    color: #c8e87a;
  }
  .logo-text em {
    font-style: normal;
    color: #ffffff;
  }
  
  .hero-text h1 {
    font-family: 'Bebas Neue', sans-serif;
    font-size: clamp(36px, 4vw, 52px);
    line-height: 1.1;
    color: #ffffff;
    letter-spacing: 0.04em;
  }
  .hero-text h1 .accent { color: #c8e87a; }
  .hero-text p {
    margin-top: 16px;
    color: rgba(255,255,255,0.55);
    font-size: 14px;
    line-height: 1.8;
  }
  
  .course-stat {
    display: flex;
    align-items: center;
    gap: 20px;
    margin-top: auto;
    padding: 20px;
    background: rgba(255,255,255,0.04);
    border-radius: 12px;
    border: 1px solid rgba(200,232,122,0.12);
  }
  .stat { display: flex; flex-direction: column; align-items: center; flex: 1; }
  .stat-num {
    font-family: 'Bebas Neue', sans-serif;
    font-size: 26px;
    color: #c8e87a;
    letter-spacing: 0.06em;
  }
  .stat-label { font-size: 11px; color: rgba(255,255,255,0.45); margin-top: 2px; }
  .stat-divider { width: 1px; height: 36px; background: rgba(255,255,255,0.1); }
  
  /* Right panel */
  .right-panel {
    flex: 1;
    background: #f5f7f2;
    padding: 48px 44px;
    display: flex;
    flex-direction: column;
  }
  
  .tab-row {
    display: flex;
    gap: 0;
    background: #e8ede3;
    border-radius: 10px;
    padding: 4px;
    margin-bottom: 32px;
  }
  .tab {
    flex: 1;
    border: none;
    background: transparent;
    padding: 10px;
    border-radius: 7px;
    font-family: 'Noto Sans JP', sans-serif;
    font-size: 14px;
    font-weight: 700;
    color: #6b7c61;
    cursor: pointer;
    transition: all 0.2s;
  }
  .tab.active {
    background: #ffffff;
    color: #1a3d1f;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  }
  
  .auth-form { display: flex; flex-direction: column; gap: 18px; }
  
  .field { display: flex; flex-direction: column; gap: 6px; }
  .field label {
    font-size: 12px;
    font-weight: 700;
    color: #3a4f35;
    letter-spacing: 0.05em;
    text-transform: uppercase;
  }
  .field input {
    padding: 12px 16px;
    border: 1.5px solid #d4dece;
    border-radius: 8px;
    font-size: 15px;
    font-family: 'Noto Sans JP', sans-serif;
    color: #1a2e16;
    background: #ffffff;
    outline: none;
    transition: border-color 0.2s, box-shadow 0.2s;
  }
  .field input:focus {
    border-color: #4d9e3f;
    box-shadow: 0 0 0 3px rgba(77,158,63,0.12);
  }
  .field input::placeholder { color: #b0bca8; }
  
  .error-msg {
    background: #fee;
    color: #c0392b;
    font-size: 13px;
    padding: 10px 14px;
    border-radius: 8px;
    border: 1px solid #f5c6cb;
  }
  .success-msg {
    background: #edfbee;
    color: #27ae60;
    font-size: 13px;
    padding: 10px 14px;
    border-radius: 8px;
    border: 1px solid #b2dfdb;
  }
  
  .submit-btn {
    margin-top: 6px;
    padding: 14px;
    background: #1f5c28;
    color: #c8e87a;
    border: none;
    border-radius: 10px;
    font-family: 'Bebas Neue', sans-serif;
    font-size: 18px;
    letter-spacing: 0.1em;
    cursor: pointer;
    transition: background 0.2s, transform 0.1s;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
  }
  .submit-btn:hover:not(:disabled) {
    background: #246b2f;
    transform: translateY(-1px);
  }
  .submit-btn:disabled { opacity: 0.6; cursor: not-allowed; }
  
  @keyframes spin { to { transform: rotate(360deg); } }
  .spinner {
    width: 18px; height: 18px;
    border: 2px solid rgba(200,232,122,0.3);
    border-top-color: #c8e87a;
    border-radius: 50%;
    animation: spin 0.7s linear infinite;
  }
  
  .switch-hint {
    margin-top: 20px;
    text-align: center;
    font-size: 13px;
    color: #7a8f73;
  }
  .switch-hint a {
    color: #2d7a35;
    font-weight: 700;
    text-decoration: none;
  }
  .switch-hint a:hover { text-decoration: underline; }
  
  @media (max-width: 680px) {
    .left-panel { display: none; }
    .right-panel { padding: 36px 28px; }
  }
  </style>