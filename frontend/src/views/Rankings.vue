<template>
  <div class="page-container">
    <div class="page-header">
      <h1>球员排行</h1>
    </div>

    <div class="rankings-list">
      <div v-for="(player, index) in players" :key="player.playerId" class="rank-row" @click="goToPlayer(player.playerId)">
        <div class="rank-badge" :class="'rank-' + (index + 1)">{{ index + 1 }}</div>
        <div class="player-avatar">{{ (player.nameCn || player.name)?.charAt(0) }}</div>
        <div class="player-info">
          <h4>{{ player.nameCn || player.name }}</h4>
          <div class="player-meta">
            <span class="club-name">{{ player.clubName || '未知俱乐部' }}</span>
            <span class="position-badge">{{ positionMap[player.position] || player.position }}</span>
            <span v-if="player.birthDate" class="age-badge">{{ calcAge(player.birthDate) }}岁</span>
          </div>
        </div>
        <div class="player-score">
          <span class="score-value">{{ Number(player.avgScore).toFixed(2) }}</span>
          <span class="score-label">评分</span>
        </div>
      </div>
    </div>

    <div v-if="players.length === 0" class="empty-state">暂无排行数据</div>

    <div class="pagination-wrapper">
      <el-pagination v-model:current-page="currentPage" :page-size="pageSize" :total="total"
        layout="prev, pager, next" @current-change="fetchRankings" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { playerApi } from '@/api'

const router = useRouter()
const players = ref<any[]>([])
const currentPage = ref(1)
const pageSize = ref(20)
const total = ref(0)

const positionMap: Record<string, string> = {
  GK: '守门员',
  DF: '后卫',
  MF: '中场',
  FW: '前锋'
}

onMounted(() => {
  fetchRankings()
})

async function fetchRankings() {
  try {
    const res = await playerApi.getRankings({
      page: currentPage.value,
      pageSize: pageSize.value
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

function calcAge(birthDate: string) {
  if (!birthDate) return ''
  const birth = new Date(birthDate)
  const today = new Date()
  let age = today.getFullYear() - birth.getFullYear()
  const m = today.getMonth() - birth.getMonth()
  if (m < 0 || (m === 0 && today.getDate() < birth.getDate())) age--
  return age
}
</script>

<style scoped lang="scss">
.rankings-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.rank-row {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 14px 18px;
  background: #ffffff;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.2s;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);

  &:hover {
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  }

  .rank-badge {
    width: 32px;
    height: 32px;
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: 700;
    font-size: 14px;
    background: #f5f5f5;
    color: #737373;
    flex-shrink: 0;

    &.rank-1 { background: rgba(255, 215, 0, 0.15); color: #d97706; }
    &.rank-2 { background: rgba(156, 163, 175, 0.15); color: #737373; }
    &.rank-3 { background: rgba(180, 83, 9, 0.12); color: #b45309; }
  }

  .player-avatar {
    width: 44px;
    height: 44px;
    border-radius: 50%;
    background: rgba(26, 86, 219, 0.1);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 18px;
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

      .age-badge {
        font-size: 11px;
        padding: 2px 8px;
        border-radius: 4px;
        background: #f5f5f5;
        color: #737373;
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
