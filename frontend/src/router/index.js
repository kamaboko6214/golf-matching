import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/',
    redirect: '/matches'
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('../pages/LoginPage.vue'),
  },
  {
    path: '/matches',
    name: 'Matches',
    component: () => import('../pages/match/MatchesPage.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/matches/new',
    name: 'MatchesNew',
    component: () => import('../pages/match/MatchesNewPage.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/matches/:id',
    name: 'MatchesShow',
    component: () => import('../pages/match/MatchesShowPage.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/matches/:id/edit',
    name: 'MatchesEdit',
    component: () => import('../pages/match/MatchesEditPage.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/chats',
    name: 'Chats',
    component: () => import('../pages/chat/ChatsPage.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/chats/:id',
    name: 'ChatsShow',
    component: () => import('../pages/chat/ChatsShowPage.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/mypage',
    name: 'MyPage',
    component: () => import('../pages/user/MyPage.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/profile',
    name: 'Profile',
    component: () => import('../pages/user/ProfilePage.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/users/:id',
    name: 'UserProfile',
    component: () => import('../pages/user/UserProfilePage.vue'),
    meta: { requiresAuth: true },
  },  
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

router.beforeEach((to) => {
  const token = localStorage.getItem('token')
  if (to.meta.requiresAuth && !token) {
    return { name: 'Login' }
  }
})

export default router