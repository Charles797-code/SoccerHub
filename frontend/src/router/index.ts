import { createRouter, createWebHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const routes: RouteRecordRaw[] = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Login.vue'),
    meta: { requiresAuth: false }
  },
  {
    path: '/register',
    name: 'Register',
    component: () => import('@/views/Register.vue'),
    meta: { requiresAuth: false }
  },
  {
    path: '/',
    component: () => import('@/views/Layout.vue'),
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        name: 'Home',
        component: () => import('@/views/Home.vue')
      },
      {
        path: 'clubs',
        name: 'Clubs',
        component: () => import('@/views/Clubs.vue')
      },
      {
        path: 'clubs/:id',
        name: 'ClubDetail',
        component: () => import('@/views/ClubDetail.vue')
      },
      {
        path: 'players',
        name: 'Players',
        component: () => import('@/views/Players.vue')
      },
      {
        path: 'players/:id',
        name: 'PlayerDetail',
        component: () => import('@/views/PlayerDetail.vue')
      },
      {
        path: 'matches',
        name: 'Matches',
        component: () => import('@/views/Matches.vue')
      },
      {
        path: 'matches/:id',
        name: 'MatchDetail',
        component: () => import('@/views/MatchDetail.vue')
      },
      {
        path: 'rankings',
        name: 'Rankings',
        component: () => import('@/views/Rankings.vue')
      },
      {
        path: 'standings',
        name: 'Standings',
        component: () => import('@/views/Standings.vue')
      },
      {
        path: 'news',
        name: 'News',
        component: () => import('@/views/News.vue')
      },
      {
        path: 'news/:id',
        name: 'NewsDetail',
        component: () => import('@/views/NewsDetail.vue')
      },
      {
        path: 'chat/:clubId',
        name: 'Chat',
        component: () => import('@/views/Chat.vue')
      },
      {
        path: 'profile',
        name: 'Profile',
        component: () => import('@/views/Profile.vue')
      },
      {
        path: 'community',
        name: 'Community',
        component: () => import('@/views/Community.vue')
      },
      {
        path: 'user/:id',
        name: 'UserDetail',
        component: () => import('@/views/UserDetail.vue')
      },
      {
        path: 'admin',
        name: 'Admin',
        component: () => import('@/views/Admin.vue'),
        meta: { requiresSuperAdmin: true }
      },
      {
        path: 'club-admin',
        name: 'ClubAdmin',
        component: () => import('@/views/ClubAdmin.vue'),
        meta: { requiresClubAdmin: true }
      }
    ]
  },
  {
    path: '/:pathMatch(.*)*',
    redirect: '/'
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  const authStore = useAuthStore()
  const requiresAuth = to.matched.some(record => record.meta.requiresAuth !== false)
  const requiresSuperAdmin = to.matched.some(record => record.meta.requiresSuperAdmin)
  const requiresClubAdmin = to.matched.some(record => record.meta.requiresClubAdmin)

  if (requiresAuth && !authStore.isLoggedIn) {
    next('/login')
  } else if (requiresSuperAdmin && authStore.user?.role !== 'SUPER_ADMIN') {
    next('/')
  } else if (requiresClubAdmin && !['CLUB_ADMIN', 'SUPER_ADMIN'].includes(authStore.user?.role || '')) {
    next('/')
  } else if ((to.path === '/login' || to.path === '/register') && authStore.isLoggedIn) {
    next('/')
  } else {
    next()
  }
})

export default router
