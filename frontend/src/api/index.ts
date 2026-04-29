import axios from 'axios'
import { ElMessage } from 'element-plus'
import router from '@/router'

const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080',
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json'
  }
})

api.interceptors.request.use(config => {
  const token = localStorage.getItem('token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

api.interceptors.response.use(
  response => {
    if (response.data && response.data.success === false) {
      ElMessage.error(response.data.message)
      return Promise.reject(response.data)
    }
    return response
  },
  error => {
    if (error.response) {
      switch (error.response.status) {
        case 401:
          localStorage.removeItem('token')
          localStorage.removeItem('user')
          ElMessage.error('Authentication expired, please login again')
          router.push('/login')
          break
        case 403:
          ElMessage.error('Access denied: insufficient permissions')
          break
        case 404:
          ElMessage.error('Resource not found')
          break
        case 500:
          ElMessage.error('Server error, please try again later')
          break
        default:
          if (error.response.data?.message) {
            ElMessage.error(error.response.data.message)
          }
      }
    } else {
      ElMessage.error('Network error, please check your connection')
    }
    return Promise.reject(error)
  }
)

export default api

export const authApi = {
  login: (data: { username: string; password: string }) =>
    api.post('/auth/login', data),
  register: (data: { username: string; password: string; nickname: string; email?: string }) =>
    api.post('/auth/register', data),
  refresh: (refreshToken: string) =>
    api.post('/auth/refresh', `"${refreshToken}"`),
  getProfile: () =>
    api.get('/auth/profile'),
  updateProfile: (data: any) =>
    api.put('/auth/profile', data),
  getMyFollows: () =>
    api.get('/auth/my-follows')
}

export const clubApi = {
  list: (params: any) =>
    api.get('/clubs', { params }),
  getById: (id: number) =>
    api.get(`/clubs/${id}`),
  getPlayers: (id: number, params: any) =>
    api.get(`/clubs/${id}/players`, { params }),
  getCoaches: (id: number) =>
    api.get(`/clubs/${id}/coaches`),
  getLeagues: () =>
    api.get('/clubs/leagues'),
  create: (data: any) =>
    api.post('/clubs', data),
  update: (id: number, data: any) =>
    api.put(`/clubs/${id}`, data),
  delete: (id: number) =>
    api.delete(`/clubs/${id}`)
}

export const playerApi = {
  list: (params: any) =>
    api.get('/players', { params }),
  getById: (id: number) =>
    api.get(`/players/${id}`),
  getRankings: (params: any) =>
    api.get('/players/rankings', { params }),
  create: (data: any) =>
    api.post('/players', data),
  update: (id: number, data: any) =>
    api.put(`/players/${id}`, data),
  transfer: (id: number, data: any) =>
    api.post(`/players/${id}/transfer`, data),
  delete: (id: number) =>
    api.delete(`/players/${id}`)
}

export const coachApi = {
  list: (params: any) =>
    api.get('/coaches', { params }),
  getById: (id: number) =>
    api.get(`/coaches/${id}`),
  getRankings: (params: any) =>
    api.get('/coaches/rankings', { params }),
  create: (data: any) =>
    api.post('/coaches', data),
  update: (id: number, data: any) =>
    api.put(`/coaches/${id}`, data),
  delete: (id: number) =>
    api.delete(`/coaches/${id}`)
}

export const matchApi = {
  list: (params: any) =>
    api.get('/matches', { params }),
  getById: (id: string) =>
    api.get(`/matches/${id}`),
  getEvents: (id: string) =>
    api.get(`/matches/${id}/events`),
  getToday: () =>
    api.get('/matches/today'),
  getLive: () =>
    api.get('/matches/live'),
  getUpcoming: (limit = 10) =>
    api.get('/matches/upcoming', { params: { limit } }),
  upsert: (data: any) =>
    api.post('/matches/upsert', data),
  delete: (matchId: string) =>
    api.delete(`/matches/${matchId}`)
}

export const predictionApi = {
  make: (data: any) =>
    api.post('/predictions', null, { params: data }),
  getForMatch: (matchId: string, userId: number) =>
    api.get(`/predictions/match/${matchId}`, { params: { userId } }),
  getUserPredictions: (userId: number) =>
    api.get(`/predictions/user/${userId}`),
  getUserPredictionsWithMatch: (userId: number) =>
    api.get(`/predictions/user/${userId}/with-match`),
  getUserPoints: (userId: number) =>
    api.get(`/predictions/user/${userId}/points`)
}

export const ratingApi = {
  submit: (data: any) =>
    api.post('/ratings', data),
  getTarget: (type: string, id: number, params: any) =>
    api.get(`/ratings/target/${type}/${id}`, { params }),
  getAverage: (type: string, id: number) =>
    api.get(`/ratings/target/${type}/${id}/average`),
  getMyRatings: (params: any) =>
    api.get('/ratings/my-ratings', { params }),
  delete: (id: number) =>
    api.delete(`/ratings/${id}`)
}

export const followApi = {
  follow: (clubId: number, isPrimary = false) =>
    api.post('/follows', { clubId, isPrimary }),
  unfollow: (clubId: number) =>
    api.delete(`/follows/${clubId}`),
  getMyFollows: () =>
    api.get('/follows/my-follows'),
  getFollowers: (clubId: number) =>
    api.get(`/follows/${clubId}/followers`)
}

export const chatApi = {
  getMessages: (clubId: number, params: any) =>
    api.get(`/chat/${clubId}/messages`, { params }),
  getRecent: (clubId: number, limit = 50) =>
    api.get(`/chat/${clubId}/recent`, { params: { limit } }),
  send: (clubId: number, content: string, messageType = 'TEXT') =>
    api.post(`/chat/${clubId}/messages`, { content, messageType }),
  delete: (clubId: number, messageId: number) =>
    api.delete(`/chat/${clubId}/messages/${messageId}`)
}

export const adminApi = {
  getStats: () =>
    api.get('/admin/dashboard/stats'),
  listUsers: (params: any) =>
    api.get('/admin/users', { params }),
  updateRole: (id: number, role: string) =>
    api.put(`/admin/users/${id}/role`, { role }),
  updateStatus: (id: number, status: string) =>
    api.put(`/admin/users/${id}/status`, { status }),
  assignClub: (id: number, managedClubId: number) =>
    api.put(`/admin/users/${id}/club`, { managedClubId }),
  getAuditLogs: (params: any) =>
    api.get('/admin/audit-logs', { params }),
  getDictionary: (params: any) =>
    api.get('/admin/dictionary', { params }),
  createDictionary: (data: any) =>
    api.post('/admin/dictionary', data),
  updateDictionary: (id: number, data: any) =>
    api.put(`/admin/dictionary/${id}`, data),
  deleteDictionary: (id: number) =>
    api.delete(`/admin/dictionary/${id}`),
  listTransfers: (params: any) =>
    api.get('/admin/transfers', { params }),
  createTransfer: (data: any) =>
    api.post('/admin/transfers', data),
  deleteTransfer: (id: number) =>
    api.delete(`/admin/transfers/${id}`),
  listMatches: (params: any) =>
    api.get('/admin/matches', { params }),
  getMatch: (id: string) =>
    api.get(`/admin/matches/${id}`),
  createMatch: (data: any) =>
    api.post('/admin/matches', data),
  updateMatch: (id: string, data: any) =>
    api.put(`/admin/matches/${id}`, data),
  deleteMatch: (id: string) =>
    api.delete(`/admin/matches/${id}`),
  listClubs: (params: any) =>
    api.get('/admin/clubs', { params }),
  createClub: (data: any) =>
    api.post('/admin/clubs', data),
  updateClub: (id: number, data: any) =>
    api.put(`/admin/clubs/${id}`, data),
  deleteClub: (id: number) =>
    api.delete(`/admin/clubs/${id}`),
  listPlayers: (params: any) =>
    api.get('/admin/players', { params }),
  createPlayer: (data: any) =>
    api.post('/admin/players', data),
  updatePlayer: (id: number, data: any) =>
    api.put(`/admin/players/${id}`, data),
  deletePlayer: (id: number) =>
    api.delete(`/admin/players/${id}`),
  finishMatch: (data: any) =>
    api.post('/admin/matches/finish', data),
  getMatchEvents: (matchId: string) =>
    api.get(`/admin/matches/${matchId}/events`)
}

export const clubAdminApi = {
  getMyClub: () =>
    api.get('/club-admin/club'),
  updateMyClub: (data: any) =>
    api.put('/club-admin/club', data),
  listMyPlayers: (params: any) =>
    api.get('/club-admin/players', { params }),
  createMyPlayer: (data: any) =>
    api.post('/club-admin/players', data),
  updateMyPlayer: (id: number, data: any) =>
    api.put(`/club-admin/players/${id}`, data),
  deleteMyPlayer: (id: number) =>
    api.delete(`/club-admin/players/${id}`),
  transferMyPlayer: (id: number, data: any) =>
    api.post(`/club-admin/players/${id}/transfer`, data),
  listMyCoaches: () =>
    api.get('/club-admin/coaches'),
  createMyCoach: (data: any) =>
    api.post('/club-admin/coaches', data),
  updateMyCoach: (id: number, data: any) =>
    api.put(`/club-admin/coaches/${id}`, data),
  deleteMyCoach: (id: number) =>
    api.delete(`/club-admin/coaches/${id}`)
}

export const standingsApi = {
  get: (params: any) =>
    api.get('/standings', { params }),
  upsert: (data: any) =>
    api.post('/standings', data),
  delete: (id: number) =>
    api.delete(`/standings/${id}`),
  getScorers: (params: any) =>
    api.get('/standings/scorers', { params }),
  getAssists: (params: any) =>
    api.get('/standings/assists', { params }),
  getYellowCards: (params: any) =>
    api.get('/standings/yellow-cards', { params }),
  getRedCards: (params: any) =>
    api.get('/standings/red-cards', { params })
}

export const newsApi = {
  list: (params: any) =>
    api.get('/news', { params }),
  getById: (id: number) =>
    api.get(`/news/${id}`),
  scrape: () =>
    api.post('/news/scrape'),
  getComments: (articleId: number, params: any) =>
    api.get(`/news/${articleId}/comments`, { params }),
  addComment: (articleId: number, data: any) =>
    api.post(`/news/${articleId}/comments`, data),
  deleteComment: (commentId: number) =>
    api.delete(`/news/comments/${commentId}`),
  create: (data: any) =>
    api.post('/news', data),
  update: (id: number, data: any) =>
    api.put(`/news/${id}`, data),
  delete: (id: number) =>
    api.delete(`/news/${id}`)
}

export const uploadApi = {
  uploadImage: (file: File) => {
    const formData = new FormData()
    formData.append('file', file)
    return api.post('/api/upload/image', formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    })
  },
  deleteImage: (path: string) =>
    api.delete('/api/upload/image', { params: { path } })
}

export const analyticsApi = {
  getStats: () =>
    api.get('/analytics/stats'),
  exportData: (type: string, format: string = 'xlsx') =>
    api.get(`/analytics/export/${type}`, {
      params: { format },
      responseType: 'blob'
    }),
  importPlayers: (file: File) => {
    const formData = new FormData()
    formData.append('file', file)
    return api.post('/analytics/import/players', formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
  },
  importMatches: (file: File) => {
    const formData = new FormData()
    formData.append('file', file)
    return api.post('/analytics/import/matches', formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
  }
}

export const socialApi = {
  getCircles: () =>
    api.get('/social/circles'),
  getPosts: (params: any) =>
    api.get('/social/admin/posts', { params }),
  pinPost: (postId: number, pinned: boolean) =>
    api.post(`/social/admin/posts/${postId}/pin`, null, { params: { pinned } }),
  essencePost: (postId: number, essence: boolean) =>
    api.post(`/social/admin/posts/${postId}/essence`, null, { params: { essence } }),
  deletePost: (postId: number) =>
    api.delete(`/social/posts/${postId}`),
  getComments: (postId: number, params: any) =>
    api.get(`/social/posts/${postId}/comments`, { params }),
  addComment: (postId: number, data: any) =>
    api.post(`/social/posts/${postId}/comments`, data),
  deleteComment: (commentId: number) =>
    api.delete(`/social/comments/${commentId}`)
}

export const seasonApi = {
  getAll: () =>
    api.get('/seasons'),
  getActive: () =>
    api.get('/seasons/active'),
  getByLeague: (league: string) =>
    api.get(`/seasons/league/${encodeURIComponent(league)}`),
  getActiveByLeague: (league: string) =>
    api.get(`/seasons/active/${encodeURIComponent(league)}`),
  startNew: (data: { league: string, seasonName: string, totalRounds: number }) =>
    api.post('/seasons/start-new', data),
  resetSeason: (league: string) =>
    api.post(`/seasons/reset/${encodeURIComponent(league)}`),
  finishSeason: (league: string) =>
    api.put(`/seasons/finish/${encodeURIComponent(league)}`)
}
