import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { authApi } from '@/api'

interface User {
  userId: number
  username: string
  nickname: string
  role: string
  email?: string
  avatarUrl?: string
  managedClubId?: number
}

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  const token = ref<string | null>(localStorage.getItem('token'))

  const isLoggedIn = computed(() => !!token.value)
  const isAdmin = computed(() => user.value?.role === 'SUPER_ADMIN' || user.value?.role === 'CLUB_ADMIN')
  const isSuperAdmin = computed(() => user.value?.role === 'SUPER_ADMIN')
  const isClubAdmin = computed(() => user.value?.role === 'CLUB_ADMIN')

  function setAuth(data: { token: string; user: User }) {
    token.value = data.token
    user.value = data.user
    localStorage.setItem('token', data.token)
    localStorage.setItem('user', JSON.stringify(data.user))
  }

  async function login(username: string, password: string) {
    const res = await authApi.login({ username, password })
    const data = res.data.data
    setAuth({
      token: data.token,
      user: {
        userId: data.userId,
        username: data.username,
        nickname: data.nickname,
        role: data.role,
        email: data.email,
        avatarUrl: data.avatarUrl,
        managedClubId: data.managedClubId
      }
    })
  }

  async function register(username: string, password: string, nickname: string, email?: string) {
    const res = await authApi.register({ username, password, nickname, email })
    return res.data
  }

  async function fetchProfile() {
    if (!token.value) return
    try {
      const res = await authApi.getProfile()
      user.value = res.data.data
    } catch {
      logout()
    }
  }

  function logout() {
    user.value = null
    token.value = null
    localStorage.removeItem('token')
    localStorage.removeItem('user')
  }

  function initAuth() {
    const storedUser = localStorage.getItem('user')
    if (storedUser && token.value) {
      user.value = JSON.parse(storedUser)
    }
  }

  return {
    user,
    token,
    isLoggedIn,
    isAdmin,
    isSuperAdmin,
    isClubAdmin,
    login,
    register,
    logout,
    fetchProfile,
    initAuth,
    setAuth
  }
})
