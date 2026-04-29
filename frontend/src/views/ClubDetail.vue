<template>
  <div class="page-container">
    <div v-if="club" class="club-detail">
      <div class="club-banner">
        <div class="banner-overlay"></div>
        <div class="banner-content">
          <div class="club-logo">
            <img v-if="club.logoUrl" :src="getImageUrl(club.logoUrl)" alt="Logo" />
            <span v-else>{{ club.shortName?.charAt(0) || club.name?.charAt(0) }}</span>
          </div>
          <div class="club-meta">
            <h1>{{ club.shortName || club.name }}</h1>
            <div class="meta-row">
              <span class="league-badge">{{ getLeagueNameCN(club.league) }}</span>
              <span class="meta-item">{{ club.city }}, {{ club.country }}</span>
              <span class="meta-item">{{ club.stadium }}</span>
            </div>
          </div>
        </div>
      </div>

      <div class="detail-tabs">
        <el-tabs v-model="activeTab">
          <el-tab-pane label="球员阵容" name="players">
            <div class="card-grid">
              <div v-for="player in players" :key="player.playerId" class="player-card" @click="goToPlayer(player.playerId)">
                <div class="player-avatar">{{ (player.nameCn || player.name)?.charAt(0) }}</div>
                <div class="player-info">
                  <h4>{{ player.nameCn || player.name }}</h4>
                  <div class="player-meta">
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
          </el-tab-pane>

          <el-tab-pane label="近期比赛" name="matches">
            <div class="matches-list">
              <div v-for="match in matches" :key="match.matchId" class="match-row">
                <div class="match-date">{{ formatMatchTime(match.matchTime) }}</div>
                <div class="match-teams">
                  <span class="team-name">{{ getClubName(match.homeClubId) }}</span>
                  <span class="match-score">
                    <span v-if="match.homeScore !== null">{{ match.homeScore }} - {{ match.awayScore }}</span>
                    <span v-else>VS</span>
                  </span>
                  <span class="team-name">{{ getClubName(match.awayClubId) }}</span>
                </div>
                <div class="match-status" :class="match.status?.toLowerCase()">{{ getStatusLabel(match.status) }}</div>
              </div>
            </div>
            <div v-if="matches.length === 0" class="empty-state">暂无比赛数据</div>
          </el-tab-pane>

          <el-tab-pane label="俱乐部信息" name="info">
            <div class="info-grid">
              <div class="info-item">
                <span class="info-label">全名</span>
                <span class="info-value">{{ club.name }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">简称</span>
                <span class="info-value">{{ club.shortName || '-' }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">联赛</span>
                <span class="info-value">{{ getLeagueNameCN(club.league) }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">城市</span>
                <span class="info-value">{{ club.city }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">国家</span>
                <span class="info-value">{{ club.country }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">主场</span>
                <span class="info-value">{{ club.stadium }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">球场容量</span>
                <span class="info-value">{{ club.stadiumCapacity?.toLocaleString() || '-' }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">成立年份</span>
                <span class="info-value">{{ club.foundedYear || '-' }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">总评分</span>
                <span class="info-value">{{ club.totalScore != null ? Number(club.totalScore).toFixed(1) : '-' }}</span>
              </div>
            </div>
          </el-tab-pane>
        </el-tabs>
      </div>
    </div>

    <div v-else class="loading-state">
      <el-skeleton :rows="8" animated />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { clubApi, playerApi, matchApi } from '@/api'

const router = useRouter()
const route = useRoute()
const club = ref<any>(null)
const players = ref<any[]>([])
const matches = ref<any[]>([])
const activeTab = ref('players')

const positionMap: Record<string, string> = {
  GK: '守门员',
  DF: '后卫',
  MF: '中场',
  FW: '前锋'
}

const leagueNameMap: Record<string, string> = {
  'La Liga': '西班牙足球甲级联赛',
  'Premier League': '英格兰足球超级联赛',
  'Bundesliga': '德国足球甲级联赛',
  'Serie A': '意大利足球甲级联赛',
  'Ligue 1': '法国足球甲级联赛'
}

function getLeagueNameCN(league: string) {
  return leagueNameMap[league] || league
}

const clubNameMap = ref<Record<number, string>>({})

function getClubName(clubId: number) {
  return clubNameMap.value[clubId] || `球队${clubId}`
}

const statusLabelMap: Record<string, string> = {
  PENDING: '未开始',
  IN_PROGRESS: '进行中',
  FINISHED: '已结束',
  LIVE: '直播中'
}

function getStatusLabel(status: string) {
  return statusLabelMap[status] || status
}

function formatMatchTime(time: string) {
  if (!time) return ''
  return new Date(time).toLocaleString('zh-CN', {
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
    hour12: false
  })
}

onMounted(async () => {
  const clubId = Number(route.params.id)
  try {
    const clubRes = await clubApi.getById(clubId)
    club.value = clubRes.data.data

    const playersRes = await playerApi.list({ clubId, page: 1, pageSize: 50 })
    players.value = playersRes.data.data?.records || []

    const matchesRes = await matchApi.list({ clubId, page: 1, pageSize: 10 })
    matches.value = matchesRes.data.data?.records || []

    const clubsRes = await clubApi.list({ page: 1, pageSize: 100 })
    const allClubs = clubsRes.data.data?.records || []
    allClubs.forEach((c: any) => {
      clubNameMap.value[c.clubId] = c.shortName || c.name
    })
  } catch (e) {
    console.error(e)
  }
})

function goToPlayer(playerId: number) {
  router.push(`/players/${playerId}`)
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

.empty-state {
  text-align: center;
  padding: $space-12 $space-4;
  color: $text-muted;
  font-size: $font-size-base;
  background: $surface-card;
  border: 1px solid $border-subtle;
  border-radius: $radius-lg;
}

.loading-state {
  padding: $space-6;
  background: $surface-card;
  border: 1px solid $border-subtle;
  border-radius: $radius-xl;
}

.detail-tabs {
  background: transparent;
}

.matches-list {
  .match-row {
    display: flex;
    align-items: center;
    gap: $space-4;
    padding: $space-3 $space-4;
    background: $surface-card;
    border: 1px solid $border-subtle;
    border-radius: $radius-lg;
    margin-bottom: $space-2;

    .match-date {
      font-size: $font-size-sm;
      color: $text-muted;
      min-width: 60px;
    }

    .match-teams {
      flex: 1;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: $space-3;

      .team-name {
        font-size: $font-size-base;
        font-weight: $font-weight-medium;
        color: $text-primary;
      }

      .match-score {
        font-size: $font-size-lg;
        font-weight: $font-weight-bold;
        color: $gold-bright;
        min-width: 50px;
        text-align: center;
      }
    }

    .match-status {
      font-size: $font-size-xs;
      padding: 3px 10px;
      border-radius: $radius-full;

      &.live, &.in_progress {
        background: rgba($danger, 0.12);
        color: $danger-light;
        border: 1px solid rgba($danger, 0.2);
      }

      &.finished {
        background: rgba($success, 0.12);
        color: $success-light;
        border: 1px solid rgba($success, 0.2);
      }

      &.pending {
        background: $surface-mid;
        color: $text-muted;
        border: 1px solid $border-subtle;
      }
    }
  }
}
</style>
