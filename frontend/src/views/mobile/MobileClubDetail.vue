<template>
  <div class="mobile-club-detail">
    <!-- Loading -->
    <div v-if="loading" class="loading">
      <div class="spinner"></div>
    </div>

    <!-- Content -->
    <template v-else-if="club">
      <!-- Header -->
      <div class="club-header">
        <div class="back-btn" @click="router.back()">
          <el-icon><ArrowLeft /></el-icon>
        </div>
        <div class="logo-wrap">
          <img v-if="club.logoUrl || club.logo" :src="getImageUrl(club.logoUrl || club.logo)" :alt="club.name" class="logo" />
          <div v-else class="logo logo--placeholder">
            {{ club.shortName?.charAt(0) || club.name?.charAt(0) }}
          </div>
        </div>
        <h1 class="name">{{ club.shortName || club.name }}</h1>
        <p class="full-name" v-if="club.shortName">{{ club.name }}</p>
        <div class="tags">
          <span class="tag">{{ getLeagueShort(club.league) }}</span>
          <span class="tag">{{ club.city || '' }}</span>
        </div>
        <!-- Follow Button -->
        <button
          class="follow-btn"
          :class="{ following: isFollowing }"
          @click="toggleFollow"
          :disabled="followingLoading"
        >
          <el-icon v-if="followingLoading"><Loading /></el-icon>
          <el-icon v-else>{{ isFollowing ? 'Check' : 'Plus' }}</el-icon>
          {{ isFollowing ? '已关注' : '关注' }}
        </button>
      </div>

      <!-- Stats -->
      <div class="stats-row">
        <div class="stat-item">
          <span class="stat-value">{{ playerCount }}</span>
          <span class="stat-label">球员</span>
        </div>
        <div class="stat-item">
          <span class="stat-value">{{ standing?.wins || 0 }}</span>
          <span class="stat-label">胜</span>
        </div>
        <div class="stat-item">
          <span class="stat-value">{{ standing?.draws || 0 }}</span>
          <span class="stat-label">平</span>
        </div>
        <div class="stat-item">
          <span class="stat-value">{{ standing?.losses || 0 }}</span>
          <span class="stat-label">负</span>
        </div>
        <div class="stat-item">
          <span class="stat-value">{{ standing?.points || 0 }}</span>
          <span class="stat-label">积分</span>
        </div>
      </div>

      <!-- Tabs -->
      <div class="tab-bar">
        <div
          v-for="tab in tabs"
          :key="tab.value"
          class="tab"
          :class="{ active: activeTab === tab.value }"
          @click="activeTab = tab.value"
        >
          {{ tab.label }}
        </div>
      </div>

      <!-- Players Tab -->
      <div v-if="activeTab === 'players'" class="tab-content">
        <div class="players-list" v-if="players.length > 0">
          <div
            v-for="player in players"
            :key="player.playerId"
            class="player-item"
            @click="router.push(`/m/players/${player.playerId}`)"
          >
            <span class="jersey-num">{{ player.jerseyNumber || '-' }}</span>
            <img v-if="player.avatarUrl" :src="getImageUrl(player.avatarUrl)" :alt="player.name" class="avatar" />
            <div v-else class="avatar avatar--placeholder">{{ (player.nameCn || player.name)?.charAt(0) }}</div>
            <div class="info">
              <span class="name">{{ player.nameCn || player.name }}</span>
              <span class="position">{{ positionMap[player.position] }}</span>
            </div>
            <span class="score">{{ Number(player.avgScore || 0).toFixed(1) }}</span>
          </div>
        </div>
        <div v-else class="empty">暂无球员</div>
      </div>

      <!-- Info Tab -->
      <div v-if="activeTab === 'info'" class="tab-content">
        <div class="info-list">
          <div class="info-row">
            <span class="info-label">成立年份</span>
            <span class="info-value">{{ club.foundedYear || '-' }}</span>
          </div>
          <div class="info-row">
            <span class="info-label">主场</span>
            <span class="info-value">{{ club.homeStadium || '-' }}</span>
          </div>
          <div class="info-row">
            <span class="info-label">城市</span>
            <span class="info-value">{{ club.city || '-' }}</span>
          </div>
          <div class="info-row">
            <span class="info-label">联赛</span>
            <span class="info-value">{{ club.league || '-' }}</span>
          </div>
        </div>
      </div>
    </template>

    <!-- Error -->
    <div v-else class="error">
      <p>加载失败</p>
      <button @click="fetchClub">重试</button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ArrowLeft, Loading } from '@element-plus/icons-vue'
import { clubApi, playerApi, followApi } from '@/api'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()

const club = ref<any>(null)
const players = ref<any[]>([])
const standing = ref<any>(null)
const loading = ref(true)
const activeTab = ref('players')
const playerCount = ref(0)
const isFollowing = ref(false)
const followingLoading = ref(false)
const myFollows = ref<any[]>([])

const positionMap: Record<string, string> = {
  GK: '门将', DF: '后卫', MF: '中场', FW: '前锋'
}

const tabs = [
  { label: '球员', value: 'players' },
  { label: '信息', value: 'info' },
]

const leagueNameMap: Record<string, string> = {
  'La Liga': '西甲',
  'Premier League': '英超',
  'Bundesliga': '德甲',
  'Serie A': '意甲',
  'Ligue 1': '法甲'
}

function getLeagueShort(league: string) {
  return leagueNameMap[league] || league || ''
}

function getImageUrl(url: string) {
  if (!url) return ''
  if (url.startsWith('http://') || url.startsWith('https://')) return url
  if (url.startsWith('/uploads/')) return url
  return '/uploads/' + url.replace(/^\//, '')
}

async function toggleFollow() {
  if (!authStore.isLoggedIn) {
    ElMessage.warning('请先登录')
    router.push('/login')
    return
  }

  followingLoading.value = true
  const clubId = Number(route.params.id)
  try {
    if (isFollowing.value) {
      await followApi.unfollow(clubId)
      isFollowing.value = false
      ElMessage.success('已取消关注')
    } else {
      await followApi.follow(clubId)
      isFollowing.value = true
      ElMessage.success('关注成功')
    }
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '操作失败')
  } finally {
    followingLoading.value = false
  }
}

async function fetchMyFollows() {
  try {
    const res = await followApi.getMyFollows()
    myFollows.value = res.data.data || []
  } catch (e) {
    console.error('获取关注列表失败', e)
  }
}

async function fetchClub() {
  loading.value = true
  try {
    const clubId = Number(route.params.id)
    const res = await clubApi.getById(clubId)
    club.value = res.data.data

    // Fetch players
    const playersRes = await playerApi.list({ page: 1, pageSize: 50, clubId })
    players.value = playersRes.data.data?.records || []
    playerCount.value = playersRes.data.data?.total || players.value.length
  } catch (e) {
    console.error('加载俱乐部失败', e)
  } finally {
    loading.value = false
  }
}

onMounted(async () => {
  authStore.initAuth()
  await fetchClub()
  await fetchMyFollows()
  // Check if this club is followed
  const clubId = Number(route.params.id)
  isFollowing.value = myFollows.value.some((f: any) => f.clubId === clubId)
})
</script>

<style scoped lang="scss">
.mobile-club-detail {
  min-height: 100vh;
  background: #0a0a0f;
  color: #fff;
  padding-bottom: 20px;
}

.loading {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 50vh;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 3px solid rgba(124, 58, 237, 0.2);
  border-top-color: #7c3aed;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.club-header {
  position: relative;
  text-align: center;
  padding: 16px;
  padding-top: 48px;
  background: linear-gradient(180deg, rgba(124, 58, 237, 0.15) 0%, transparent 100%);
}

.back-btn {
  position: absolute;
  top: 12px;
  left: 16px;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.1);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  z-index: 10;

  &:active {
    background: rgba(255, 255, 255, 0.2);
  }
}

.logo-wrap {
  margin-bottom: 16px;
}

.logo {
  width: 100px;
  height: 100px;
  border-radius: 50%;
  object-fit: cover;
  border: 3px solid rgba(124, 58, 237, 0.5);
  box-shadow: 0 0 30px rgba(124, 58, 237, 0.3);

  &--placeholder {
    background: linear-gradient(135deg, #7c3aed, #6d28d9);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 40px;
    font-weight: 700;
    color: #fff;
  }
}

.name {
  font-size: 24px;
  font-weight: 700;
  margin: 0 0 4px;
}

.full-name {
  font-size: 14px;
  color: rgba(255, 255, 255, 0.5);
  margin: 0 0 12px;
}

.tags {
  display: flex;
  justify-content: center;
  gap: 8px;
}

.tag {
  font-size: 12px;
  padding: 4px 12px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 12px;
  color: rgba(255, 255, 255, 0.7);
}

.follow-btn {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  margin-top: 12px;
  padding: 10px 20px;
  background: #7c3aed;
  border: none;
  border-radius: 20px;
  color: #fff;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;

  &:active {
    transform: scale(0.95);
  }

  &.following {
    background: rgba(255, 255, 255, 0.1);
    border: 1px solid rgba(255, 255, 255, 0.2);
    color: rgba(255, 255, 255, 0.8);
  }

  &:disabled {
    opacity: 0.7;
    cursor: not-allowed;
  }
}

.stats-row {
  display: flex;
  justify-content: space-around;
  background: rgba(255, 255, 255, 0.03);
  margin: 16px;
  border-radius: 12px;
  padding: 16px;
}

.stat-item {
  text-align: center;
}

.stat-value {
  display: block;
  font-size: 20px;
  font-weight: 700;
  background: linear-gradient(135deg, #fbbf24, #f59e0b);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.stat-label {
  font-size: 11px;
  color: rgba(255, 255, 255, 0.5);
}

.tab-bar {
  display: flex;
  padding: 0 16px;
  gap: 8px;
  margin-bottom: 16px;
}

.tab {
  flex: 1;
  text-align: center;
  padding: 10px;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 10px;
  font-size: 14px;
  color: rgba(255, 255, 255, 0.6);
  cursor: pointer;
  transition: all 0.2s;

  &.active {
    background: #7c3aed;
    color: #fff;
  }
}

.tab-content {
  padding: 0 16px;
}

.players-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.player-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px;
  background: rgba(255, 255, 255, 0.03);
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.2s;

  &:active {
    background: rgba(255, 255, 255, 0.06);
  }
}

.jersey-num {
  width: 28px;
  font-size: 14px;
  font-weight: 700;
  color: rgba(255, 255, 255, 0.4);
  text-align: center;
}

.avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
  flex-shrink: 0;

  &--placeholder {
    background: rgba(124, 58, 237, 0.2);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 16px;
    font-weight: 600;
    color: #a78bfa;
  }
}

.info {
  flex: 1;

  .name {
    display: block;
    font-size: 14px;
    font-weight: 500;
    color: #fff;
  }

  .position {
    font-size: 12px;
    color: rgba(255, 255, 255, 0.5);
  }
}

.score {
  font-size: 16px;
  font-weight: 700;
  background: linear-gradient(135deg, #fbbf24, #f59e0b);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.info-list {
  background: rgba(255, 255, 255, 0.03);
  border-radius: 12px;
  overflow: hidden;
}

.info-row {
  display: flex;
  justify-content: space-between;
  padding: 14px 16px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);

  &:last-child {
    border-bottom: none;
  }
}

.info-label {
  font-size: 14px;
  color: rgba(255, 255, 255, 0.5);
}

.info-value {
  font-size: 14px;
  font-weight: 500;
  color: #fff;
}

.empty {
  text-align: center;
  padding: 32px;
  color: rgba(255, 255, 255, 0.4);
}

.error {
  text-align: center;
  padding: 48px 16px;
  color: rgba(255, 255, 255, 0.6);

  button {
    margin-top: 16px;
    padding: 10px 24px;
    background: #7c3aed;
    border: none;
    border-radius: 20px;
    color: #fff;
    cursor: pointer;
  }
}
</style>
