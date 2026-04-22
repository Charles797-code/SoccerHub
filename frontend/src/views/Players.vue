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
.player-card {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 16px;
  background: #ffffff;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.2s;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);

  &:hover {
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  }

  .player-avatar {
    width: 48px;
    height: 48px;
    border-radius: 50%;
    background: rgba(26, 86, 219, 0.1);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 20px;
    color: #1a56db;
    flex-shrink: 0;
  }

  .player-info {
    flex: 1;
    min-width: 0;

    h4 {
      margin: 0;
      font-size: 15px;
      font-weight: 500;
      color: #262626;
    }

    .player-meta {
      display: flex;
      align-items: center;
      gap: 8px;
      margin-top: 4px;

      .club-name {
        font-size: 13px;
        color: #737373;
      }

      .position-badge {
        font-size: 11px;
        padding: 2px 8px;
        border-radius: 4px;
        background: rgba(26, 86, 219, 0.1);
        color: #1a56db;
      }

      .jersey-number {
        font-size: 12px;
        color: #a3a3a3;
      }
    }
  }

  .player-score {
    text-align: center;

    .score-value {
      display: block;
      font-size: 20px;
      font-weight: 700;
      color: #1a56db;
    }

    .score-label {
      font-size: 10px;
      color: #a3a3a3;
    }
  }
}

.pagination-wrapper {
  display: flex;
  justify-content: center;
  margin-top: 24px;
}

.empty-state {
  text-align: center;
  padding: 40px;
  color: #737373;
  font-size: 14px;
  background: #ffffff;
  border-radius: 10px;
}
</style>
