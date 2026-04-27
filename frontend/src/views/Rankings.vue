<template>
  <div class="page-container">
    <div class="page-header">
      <h1>球员排行</h1>
    </div>

    <div class="rankings-list">
      <div v-for="(player, index) in players" :key="player.playerId" class="rank-row" @click="goToPlayer(player.playerId)">
        <div class="rank-badge" :class="'rank-' + (index + 1)">{{ index + 1 }}</div>
        <div class="player-avatar">
          <img v-if="player.avatarUrl && player.avatarUrl.length > 0" :src="getImageUrl(player.avatarUrl)" alt="头像" />
          <span v-else>{{ (player.nameCn || player.name)?.charAt(0) }}</span>
        </div>
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

function getImageUrl(path: string) {
  if (!path) return ''
  if (path.startsWith('http://') || path.startsWith('https://')) return path
  if (path.startsWith('/uploads/')) return path
  return '/uploads/' + path.replace(/^\//, '')
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
  margin-bottom: $space-5;
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
