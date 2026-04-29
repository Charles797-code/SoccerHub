<template>
  <div class="page-container">
    <div class="page-header">
      <h1>球员</h1>
      <div class="header-actions">
        <el-input v-model="searchKeyword" placeholder="搜索球员..." size="default" clearable
          style="width: 200px;" @keyup.enter="fetchPlayers" />
        <el-select v-model="selectedPosition" placeholder="按位置筛选" clearable size="default"
          style="width: 140px;">
          <el-option v-for="pos in positions" :key="pos.value" :label="pos.label" :value="pos.value" />
        </el-select>
      </div>
    </div>

    <div class="card-grid">
      <div v-for="player in players" :key="player.playerId" class="player-card" @click="goToPlayer(player.playerId)">
        <div class="player-avatar">{{ (player.nameCn || player.name)?.charAt(0) }}</div>
        <div class="player-info">
          <h4>{{ player.nameCn || player.name }}</h4>
          <div class="player-meta">
            <span class="club-name">{{ player.clubName }}</span>
            <span class="position-badge">{{ positionMap[player.position] || player.position }}</span>
            <span class="jersey-number" v-if="player.jerseyNumber">#{{ player.jerseyNumber }}</span>
          </div>
        </div>
        <div class="player-score">
          <span class="score-value">{{ player.avgScore != null ? Number(player.avgScore).toFixed(1) : '-' }}</span>
          <span class="score-label">评分</span>
        </div>
      </div>
    </div>

    <div v-if="players.length === 0" class="empty-state">暂无球员数据</div>

    <div class="pagination-wrapper">
      <el-pagination v-model:current-page="currentPage" :page-size="pageSize" :total="total"
        layout="prev, pager, next" @current-change="fetchPlayers" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { playerApi } from '@/api'

const router = useRouter()
const players = ref<any[]>([])
const searchKeyword = ref('')
const selectedPosition = ref('')
const currentPage = ref(1)
const pageSize = ref(20)
const total = ref(0)

const positionMap: Record<string, string> = {
  GK: '守门员',
  DF: '后卫',
  MF: '中场',
  FW: '前锋'
}

const positions = [
  { value: 'GK', label: '守门员' },
  { value: 'DF', label: '后卫' },
  { value: 'MF', label: '中场' },
  { value: 'FW', label: '前锋' }
]

watch(selectedPosition, () => {
  currentPage.value = 1
  fetchPlayers()
})

onMounted(() => {
  fetchPlayers()
})

async function fetchPlayers() {
  try {
    const res = await playerApi.list({
      page: currentPage.value,
      pageSize: pageSize.value,
      keyword: searchKeyword.value || undefined,
      position: selectedPosition.value || undefined
    })
    players.value = res.data.data?.records || []
    total.value = res.data.data?.total || 0
  } catch (e) {
    console.error(e)
  }
}

function goToPlayer(playerId: number) {
  router.push(`/players/${playerId}`)
}
</script>

<style scoped lang="scss">
@use '@/styles/tokens' as *;

.page-header {
  h1 {
    font-family: $font-display;
    font-size: $font-size-2xl;
    font-weight: $font-weight-bold;
    color: $text-primary;
    letter-spacing: $letter-spacing-tight;
    margin: 0;
  }
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: $space-5;
}

.header-actions {
  display: flex;
  gap: $space-3;
  align-items: center;
}

.empty-state {
  text-align: center;
  padding: $space-12 $space-4;
  color: $text-muted;
  font-size: $font-size-base;
  background: $surface-card;
  border: 1px solid $border-subtle;
  border-radius: $radius-lg;
}
</style>
