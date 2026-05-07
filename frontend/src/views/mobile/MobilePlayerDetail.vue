<template>
  <div class="mobile-player-detail">
    <!-- Loading -->
    <div v-if="loading" class="loading">
      <div class="spinner"></div>
    </div>

    <!-- Content -->
    <template v-else-if="player">
      <!-- Header -->
      <div class="player-header">
        <div class="back-btn" @click="router.back()">
          <el-icon><ArrowLeft /></el-icon>
        </div>
        <div class="avatar-wrap">
          <img v-if="player.avatarUrl" :src="getImageUrl(player.avatarUrl)" :alt="player.name" class="avatar" />
          <div v-else class="avatar avatar--placeholder">
            {{ (player.nameCn || player.name)?.charAt(0) }}
          </div>
        </div>
        <h1 class="name">{{ player.nameCn || player.name }}</h1>
        <p class="en-name" v-if="player.nameCn">{{ player.name }}</p>
        <div class="tags">
          <span class="tag tag--position">{{ positionMap[player.position] }}</span>
          <span class="tag">{{ clubName }}</span>
          <span class="tag tag--status" :class="getStatusClass(player.status)">{{ getStatusLabel(player.status) }}</span>
        </div>
      </div>

      <!-- Stats Cards -->
      <div class="stats-grid">
        <div class="stat-card">
          <span class="stat-value">{{ Number(player.avgScore || 0).toFixed(1) }}</span>
          <span class="stat-label">平均评分</span>
        </div>
        <div class="stat-card">
          <span class="stat-value">{{ player.totalRatings || 0 }}</span>
          <span class="stat-label">评分次数</span>
        </div>
        <div class="stat-card">
          <span class="stat-value">{{ formatMarketValue(player.marketValue) }}</span>
          <span class="stat-label">身价</span>
        </div>
      </div>

      <!-- Info Section -->
      <div class="info-section">
        <h3 class="section-title">球员信息</h3>
        <div class="info-grid">
          <div class="info-item">
            <span class="info-label">球衣号码</span>
            <span class="info-value">{{ player.jerseyNumber || '-' }}</span>
          </div>
          <div class="info-item">
            <span class="info-label">国籍</span>
            <span class="info-value">{{ player.nationality || '-' }}</span>
          </div>
          <div class="info-item">
            <span class="info-label">出生日期</span>
            <span class="info-value">{{ player.birthDate ? player.birthDate.substring(0, 10) : '-' }}</span>
          </div>
          <div class="info-item">
            <span class="info-label">年龄</span>
            <span class="info-value">{{ calcAge(player.birthDate) }}</span>
          </div>
          <div class="info-item">
            <span class="info-label">身高</span>
            <span class="info-value">{{ player.heightCm ? player.heightCm + 'cm' : '-' }}</span>
          </div>
          <div class="info-item">
            <span class="info-label">体重</span>
            <span class="info-value">{{ player.weightKg ? player.weightKg + 'kg' : '-' }}</span>
          </div>
        </div>
      </div>

      <!-- Rating Section -->
      <div class="rating-section" v-if="authStore.isLoggedIn">
        <h3 class="section-title">评分</h3>
        <div class="rating-card">
          <div class="star-row">
            <span v-for="n in 5" :key="n" class="star" :class="{ active: n <= ratingScore }" @click="ratingScore = n">
              <el-icon><Star /></el-icon>
            </span>
          </div>
          <button class="rate-btn" @click="submitRating" :disabled="ratingLoading">
            {{ ratingLoading ? '提交中...' : '提交评分' }}
          </button>
        </div>
      </div>
    </template>

    <!-- Error -->
    <div v-else class="error">
      <p>加载失败</p>
      <button @click="fetchPlayer">重试</button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ArrowLeft, Star } from '@element-plus/icons-vue'
import { playerApi, clubApi } from '@/api'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()

const player = ref<any>(null)
const loading = ref(true)
const clubName = ref('')
const ratingScore = ref(5)
const ratingLoading = ref(false)

const positionMap: Record<string, string> = {
  GK: '门将', DF: '后卫', MF: '中场', FW: '前锋'
}

function getImageUrl(url: string) {
  if (!url) return ''
  if (url.startsWith('http://') || url.startsWith('https://')) return url
  if (url.startsWith('/uploads/')) return url
  return '/uploads/' + url.replace(/^\//, '')
}

function getStatusLabel(status: string) {
  const map: Record<string, string> = {
    ACTIVE: '活跃', INJURED: '受伤', FREE: '自由身', RETIRED: '退役'
  }
  return map[status] || status
}

function getStatusClass(status: string) {
  const map: Record<string, string> = {
    ACTIVE: 'status--active', INJURED: 'status--injured', FREE: 'status--free', RETIRED: 'status--retired'
  }
  return map[status] || ''
}

function formatMarketValue(value: number) {
  if (!value) return '-'
  if (value >= 100000000) return (value / 100000000).toFixed(1) + '亿'
  if (value >= 10000) return (value / 10000).toFixed(0) + '万'
  return value.toString()
}

function calcAge(birthDate: string) {
  if (!birthDate) return '-'
  const birth = new Date(birthDate)
  const today = new Date()
  let age = today.getFullYear() - birth.getFullYear()
  const m = today.getMonth() - birth.getMonth()
  if (m < 0 || (m === 0 && today.getDate() < birth.getDate())) age--
  return age + '岁'
}

async function fetchPlayer() {
  loading.value = true
  try {
    const playerId = Number(route.params.id)
    const res = await playerApi.getById(playerId)
    player.value = res.data.data

    if (player.value?.clubId) {
      const clubRes = await clubApi.getById(player.value.clubId)
      clubName.value = clubRes.data.data?.shortName || clubRes.data.data?.name || ''
    }
  } catch (e) {
    console.error('加载球员失败', e)
  } finally {
    loading.value = false
  }
}

async function submitRating() {
  if (!authStore.isLoggedIn) {
    ElMessage.warning('请先登录')
    router.push('/login')
    return
  }

  ratingLoading.value = true
  try {
    await playerApi.rate(Number(route.params.id), { score: ratingScore.value })
    ElMessage.success('评分成功')
    fetchPlayer()
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '评分失败')
  } finally {
    ratingLoading.value = false
  }
}

onMounted(() => {
  authStore.initAuth()
  fetchPlayer()
})
</script>

<style scoped lang="scss">
.mobile-player-detail {
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

.player-header {
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

.avatar-wrap {
  margin-bottom: 16px;
}

.avatar {
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

.en-name {
  font-size: 14px;
  color: rgba(255, 255, 255, 0.5);
  margin: 0 0 12px;
}

.tags {
  display: flex;
  justify-content: center;
  gap: 8px;
  flex-wrap: wrap;
}

.tag {
  font-size: 12px;
  padding: 4px 12px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 12px;
  color: rgba(255, 255, 255, 0.7);

  &--position {
    background: rgba(124, 58, 237, 0.2);
    color: #a78bfa;
  }

  &--status.status--active { background: rgba(34, 197, 94, 0.2); color: #22c55e; }
  &--status.status--injured { background: rgba(245, 158, 11, 0.2); color: #f59e0b; }
  &--status.status--free { background: rgba(124, 58, 237, 0.2); color: #a78bfa; }
  &--status.status--retired { background: rgba(255, 255, 255, 0.1); color: rgba(255, 255, 255, 0.4); }
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
  padding: 16px;
}

.stat-card {
  background: rgba(255, 255, 255, 0.03);
  border-radius: 12px;
  padding: 16px;
  text-align: center;
}

.stat-value {
  display: block;
  font-size: 24px;
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

.info-section, .rating-section {
  padding: 0 16px;
  margin-bottom: 20px;
}

.section-title {
  font-size: 16px;
  font-weight: 600;
  margin: 0 0 12px;
  color: #fff;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
}

.info-item {
  background: rgba(255, 255, 255, 0.03);
  border-radius: 10px;
  padding: 12px;
}

.info-label {
  display: block;
  font-size: 11px;
  color: rgba(255, 255, 255, 0.4);
  margin-bottom: 4px;
}

.info-value {
  font-size: 15px;
  font-weight: 600;
  color: #fff;
}

.rating-card {
  background: rgba(255, 255, 255, 0.03);
  border-radius: 12px;
  padding: 20px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.star-row {
  display: flex;
  gap: 8px;
}

.star {
  font-size: 28px;
  color: rgba(255, 255, 255, 0.2);
  cursor: pointer;
  transition: all 0.2s;

  &.active {
    color: #fbbf24;
    filter: drop-shadow(0 0 6px rgba(251, 191, 36, 0.5));
  }

  &:active {
    transform: scale(1.2);
  }
}

.rate-btn {
  padding: 10px 20px;
  background: linear-gradient(135deg, #7c3aed, #6d28d9);
  border: none;
  border-radius: 20px;
  color: #fff;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;

  &:active {
    transform: scale(0.95);
  }

  &:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }
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
