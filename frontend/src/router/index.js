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
    component: () => import('../pages/MatchesPage.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/matches/new',
    name: 'MatchesNew',
    component: () => import('../pages/MatchesNewPage.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/matches/:id',
    name: 'MatchesShow',
    component: () => import('../pages/MatchesShowPage.vue'),
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