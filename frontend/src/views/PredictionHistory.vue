<template>
  <div class="page-container">
    <div class="page-header">
      <h1>🎯 我的竞猜</h1>
      <div class="points-display">
        <span class="points-label">总积分:</span>
        <span class="points-value">{{ userPoints }}</span>
      </div>
    </div>

    <div class="prediction-stats">
      <div class="stat-card">
        <div class="stat-value">{{ totalPredictions }}</div>
        <div class="stat-label">竞猜总数</div>
      </div>
      <div class="stat-card">
        <div class="stat-value">{{ correctPredictions }}</div>
        <div class="stat-label">猜对次数</div>
      </div>
      <div class="stat-card">
        <div class="stat-value">{{ correctRate }}%</div>
        <div class="stat-label">命中率</div>
      </div>
      <div class="stat-card">
        <div class="stat-value">{{ totalEarned }}</div>
        <div class="stat-label">累计积分</div>
      </div>
    </div>

    <div class="prediction-list">
      <div v-if="loading" class="loading-state">加载中...</div>
      <div v-else-if="predictions.length === 0" class="empty-state">
        <div class="empty-icon">🎯</div>
        <div class="empty-text">暂无竞猜记录</div>
        <div class="empty-subtext">去比赛详情页参与竞猜吧！</div>
      </div>

      <div v-for="p in predictions" :key="p.predictionId" class="prediction-card" :class="p.status?.toLowerCase()">
        <div class="prediction-header">
          <div class="match-info">
            <span class="match-teams">{{ getMatchLabel(p) }}</span>
            <span class="match-time">{{ formatTime(p.matchTime) }}</span>
          </div>
          <div class="prediction-status" :class="p.status?.toLowerCase()">
            {{ getStatusLabel(p.status) }}
          </div>
        </div>
        <div class="prediction-body">
          <div class="prediction-item">
            <span class="item-label">我的预测:</span>
            <span class="item-value">{{ getResultLabel(p.predictedResult) }}</span>
          </div>
          <div v-if="p.status === 'SETTLED'" class="prediction-item">
            <span class="item-label">开奖结果:</span>
            <span class="item-value result">{{ getResultLabel(p.actualResult) }}</span>
          </div>
          <div v-if="p.pointsEarned !== null && p.pointsEarned !== undefined" class="prediction-item">
            <span class="item-label">获得积分:</span>
            <span class="item-value points" :class="{ positive: p.pointsEarned > 0 }">
              {{ p.pointsEarned > 0 ? '+' : '' }}{{ p.pointsEarned }}
            </span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { predictionApi, clubApi } from '@/api'
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()
const predictions = ref<any[]>([])
const userPoints = ref(0)
const clubMap = ref<Record<number, any>>({})
const loading = ref(false)

const totalPredictions = computed(() => predictions.value.length)
const correctPredictions = computed(() => predictions.value.filter(p => p.pointsEarned > 0).length)
const correctRate = computed(() => {
  if (totalPredictions.value === 0) return 0
  return Math.round((correctPredictions.value / totalPredictions.value) * 100)
})
const totalEarned = computed(() => {
  return predictions.value.reduce((sum, p) => sum + (p.pointsEarned || 0), 0)
})

function getResultLabel(result: string) {
  const map: Record<string, string> = {
    HOME_WIN: '主队胜',
    AWAY_WIN: '客队胜',
    DRAW: '平局'
  }
  return map[result] || result
}

function getStatusLabel(status: string) {
  if (status === 'PENDING') return '待开奖'
  if (status === 'SETTLED') return '已结算'
  return status
}

function getMatchLabel(p: any) {
  const homeName = clubMap.value[p.homeClubId] || `主队(${p.homeClubId})`
  const awayName = clubMap.value[p.awayClubId] || `客队(${p.awayClubId})`
  return `${homeName} vs ${awayName}`
}

function formatTime(time: string) {
  if (!time) return ''
  return new Date(time).toLocaleString('zh-CN', {
    month: 'short', day: 'numeric',
    hour: '2-digit', minute: '2-digit', hour12: false
  })
}

onMounted(async () => {
  if (!authStore.user) return

  loading.value = true
  try {
    const pointsRes = await predictionApi.getUserPoints(authStore.user.userId)
    userPoints.value = pointsRes.data.data?.points || 0
  } catch (e) { console.error(e) }

  try {
    const clubRes = await clubApi.list({ pageSize: 100 })
    const clubs = clubRes.data.data?.records || clubRes.data.data || []
    clubs.forEach((c: any) => {
      clubMap.value[c.clubId] = c.shortName || c.name
    })
  } catch (e) { console.error(e) }

  try {
    const predRes = await predictionApi.getUserPredictionsWithMatch(authStore.user.userId)
    predictions.value = predRes.data.data || []
  } catch (e) { console.error(e) } finally {
    loading.value = false
  }
})
</script>

<style scoped lang="scss">
@use '@/styles/tokens' as *;

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: $space-5;
}

.page-header h1 {
  font-size: $font-size-2xl;
  font-weight: bold;
  color: $text-primary;
}

.points-display {
  display: flex;
  align-items: center;
  gap: $space-2;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: $space-2 $space-4;
  border-radius: $radius-full;
}

.points-label {
  color: rgba(255, 255, 255, 0.8);
  font-size: $font-size-sm;
}

.points-value {
  color: white;
  font-weight: bold;
  font-size: $font-size-lg;
}

.prediction-stats {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: $space-4;
  margin-bottom: $space-5;
}

.stat-card {
  background: $surface-card;
  border: 1px solid $border-subtle;
  border-radius: $radius-lg;
  padding: $space-4;
  text-align: center;
}

.stat-value {
  font-size: $font-size-2xl;
  font-weight: bold;
  color: $text-primary;
}

.stat-label {
  font-size: $font-size-sm;
  color: $text-muted;
  margin-top: $space-1;
}

.loading-state {
  text-align: center;
  padding: $space-10;
  color: $text-muted;
}

.empty-state {
  text-align: center;
  padding: $space-10;
  background: $surface-card;
  border: 1px solid $border-subtle;
  border-radius: $radius-xl;
}

.empty-icon {
  font-size: 48px;
  margin-bottom: $space-3;
}

.empty-text {
  font-size: $font-size-lg;
  color: $text-primary;
  margin-bottom: $space-2;
}

.empty-subtext {
  font-size: $font-size-sm;
  color: $text-muted;
}

.prediction-card {
  background: $surface-card;
  border: 1px solid $border-subtle;
  border-radius: $radius-xl;
  padding: $space-4;
  margin-bottom: $space-3;

  &.pending {
    border-left: 3px solid #f59e0b;
  }

  &.settled {
    border-left: 3px solid #10b981;
  }
}

.prediction-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: $space-3;
}

.match-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.match-teams {
  font-weight: 600;
  color: $text-primary;
}

.match-time {
  font-size: $font-size-xs;
  color: $text-muted;
}

.prediction-status {
  font-size: $font-size-xs;
  font-weight: 500;
  padding: 2px 8px;
  border-radius: $radius-sm;

  &.pending {
    background: rgba(245, 158, 11, 0.2);
    color: #f59e0b;
  }

  &.settled {
    background: rgba(16, 185, 129, 0.2);
    color: #10b981;
  }
}

.prediction-body {
  display: flex;
  gap: $space-6;
  flex-wrap: wrap;
}

.prediction-item {
  display: flex;
  align-items: center;
  gap: $space-2;
}

.item-label {
  font-size: $font-size-sm;
  color: $text-muted;
}

.item-value {
  font-weight: 500;
  color: $text-primary;

  &.result {
    color: $text-secondary;
  }

  &.points {
    color: $text-muted;

    &.positive {
      color: #10b981;
      font-weight: bold;
    }
  }
}
</style>