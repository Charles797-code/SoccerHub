<template>
  <div class="prediction-admin">
    <div class="admin-header">
      <h3>🎯 竞猜管理</h3>
      <el-button type="primary" @click="fetchSettledMatches">刷新</el-button>
    </div>

    <div v-if="loading" class="loading-state">加载中...</div>

    <div class="matches-section">
      <div class="section-header">
        <h4>已结束的比赛（可结算）</h4>
        <el-checkbox v-model="showAllFinished" label="显示全部" />
      </div>
      <div v-if="finishedMatches.length === 0" class="empty-state">
        暂无待结算的比赛
      </div>
      <el-table v-else :data="finishedMatches" size="small" stripe>
        <el-table-column label="比赛信息">
          <template #default="{ row }">
            <div class="match-cell">
              <span class="match-teams">{{ getMatchLabel(row) }}</span>
              <span class="match-time">{{ formatTime(row.matchTime) }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="比分" width="100">
          <template #default="{ row }">
            {{ row.homeScore }} - {{ row.awayScore }}
          </template>
        </el-table-column>
        <el-table-column label="联赛" width="100">
          <template #default="{ row }">
            {{ row.league || '-' }}
          </template>
        </el-table-column>
        <el-table-column label="竞猜人数" width="120">
          <template #default="{ row }">
            <span class="prediction-count">
              <span class="pending">{{ pendingPredictionCounts[row.matchId] || 0 }}</span> /
              <span class="settled">{{ settledPredictionCounts[row.matchId] || 0 }}</span>
            </span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150">
          <template #default="{ row }">
            <template v-if="pendingPredictionCounts[row.matchId] > 0">
              <el-button
                type="success"
                size="small"
                :loading="settlingMatchId === row.matchId"
                @click="settleMatch(row)"
              >
                结算
              </el-button>
            </template>
            <el-tag v-else type="info" size="small">已结算</el-tag>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <el-dialog v-model="resultDialogVisible" title="结算结果" width="400px">
      <div v-if="settleResult" class="settle-result">
        <div class="result-item">
          <span class="label">比赛:</span>
          <span class="value">{{ settleResult.matchId }}</span>
        </div>
        <div class="result-item">
          <span class="label">开奖结果:</span>
          <span class="value">{{ getResultLabel(settleResult.actualResult) }}</span>
        </div>
        <div class="result-item">
          <span class="label">参与人数:</span>
          <span class="value">{{ settleResult.totalPredictions }}</span>
        </div>
        <div class="result-item">
          <span class="label">猜对人数:</span>
          <span class="value">{{ settleResult.correctPredictions }}</span>
        </div>
        <div class="result-item">
          <span class="label">发放积分:</span>
          <span class="value points">{{ settleResult.totalPointsDistributed }}</span>
        </div>
      </div>
      <template #footer>
        <el-button type="primary" @click="resultDialogVisible = false">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, watch, onMounted } from 'vue'
import { clubApi } from '@/api'
import api from '@/api'
import { ElMessage } from 'element-plus'

const loading = ref(false)
const finishedMatches = ref<any[]>([])
const predictionCounts = ref<Record<string, number>>({})
const pendingPredictionCounts = ref<Record<string, number>>({})
const settledPredictionCounts = ref<Record<string, number>>({})
const clubMap = ref<Record<number, any>>({})
const resultDialogVisible = ref(false)
const settleResult = ref<any>(null)
const settlingMatchId = ref<string | null>(null)
const showAllFinished = ref(false)

function getMatchLabel(match: any) {
  const homeName = clubMap.value[match.homeClubId] || `主队(${match.homeClubId})`
  const awayName = clubMap.value[match.awayClubId] || `客队(${match.awayClubId})`
  return `${homeName} vs ${awayName}`
}

function formatTime(time: string) {
  if (!time) return ''
  return new Date(time).toLocaleString('zh-CN', {
    month: 'short', day: 'numeric',
    hour: '2-digit', minute: '2-digit', hour12: false
  })
}

function getResultLabel(result: string) {
  const map: Record<string, string> = {
    HOME_WIN: '主队胜',
    AWAY_WIN: '客队胜',
    DRAW: '平局'
  }
  return map[result] || result
}

function getPredictionCount(matchId: string) {
  return predictionCounts.value[matchId] || 0
}

async function fetchClubs() {
  try {
    const res = await clubApi.list({ pageSize: 100 })
    const clubs = res.data.data?.records || res.data.data || []
    clubs.forEach((c: any) => {
      clubMap.value[c.clubId] = c.shortName || c.name
    })
  } catch (e) {
    console.error(e)
  }
}

async function fetchSettledMatches() {
  loading.value = true
  try {
    const res = await api.get('/predictions/admin/settled-matches')
    const allMatches = res.data.data || []
    const pendingCounts: Record<string, number> = {}
    const settledCounts: Record<string, number> = {}

    for (const match of allMatches) {
      try {
        const predRes = await api.get(`/predictions/match/${match.matchId}/all`)
        const predictions = predRes.data.data || []
        pendingCounts[match.matchId] = predictions.filter((p: any) => p.status === 'PENDING').length
        settledCounts[match.matchId] = predictions.filter((p: any) => p.status === 'SETTLED').length
      } catch (e) {
        pendingCounts[match.matchId] = 0
        settledCounts[match.matchId] = 0
      }
    }

    pendingPredictionCounts.value = pendingCounts
    settledPredictionCounts.value = settledCounts
    predictionCounts.value = pendingCounts
    if (showAllFinished.value) {
      finishedMatches.value = allMatches
    } else {
      finishedMatches.value = allMatches.filter(m => pendingCounts[m.matchId] > 0)
    }
  } catch (e: any) {
    ElMessage.error('获取比赛列表失败: ' + (e.response?.data?.message || e.message))
  } finally {
    loading.value = false
  }
}

async function settleMatch(match: any) {
  settlingMatchId.value = match.matchId
  try {
    console.log('Settling match:', match.matchId)
    const res = await api.post(`/predictions/settle/${match.matchId}`)
    console.log('Settle result:', res.data)
    settleResult.value = res.data.data
    resultDialogVisible.value = true
    await fetchSettledMatches()
  } catch (e: any) {
    console.error('Settle error:', e)
    ElMessage.error(e.response?.data?.message || e.message || '结算失败')
  } finally {
    settlingMatchId.value = null
  }
}

onMounted(async () => {
  await fetchClubs()
  await fetchSettledMatches()
})

watch(showAllFinished, async () => {
  await fetchSettledMatches()
})
</script>

<style scoped lang="scss">
@use '@/styles/tokens' as *;

.prediction-admin {
  padding: $space-4;
}

.admin-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: $space-4;

  h3 {
    margin: 0;
    font-size: $font-size-lg;
    color: $text-primary;
  }
}

.loading-state {
  text-align: center;
  padding: $space-8;
  color: $text-muted;
}

.empty-state {
  text-align: center;
  padding: $space-6;
  background: $surface-elevated;
  border-radius: $radius-md;
  color: $text-muted;
}

.matches-section {
  h4 {
    margin: 0;
    font-size: $font-size-base;
    color: $text-secondary;
  }

  .section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: $space-3;
  }
}

.match-cell {
  display: flex;
  flex-direction: column;
  gap: 2px;

  .match-teams {
    font-weight: 600;
    color: $text-primary;
  }

  .match-time {
    font-size: $font-size-xs;
    color: $text-muted;
  }
}

.prediction-count {
  .pending {
    color: #f59e0b;
    font-weight: 600;
  }

  .settled {
    color: #10b981;
  }
}

.settle-result {
  display: flex;
  flex-direction: column;
  gap: $space-3;
}

.result-item {
  display: flex;
  justify-content: space-between;

  .label {
    color: $text-muted;
  }

  .value {
    font-weight: 500;
    color: $text-primary;

    &.points {
      color: #10b981;
    }
  }
}
</style>