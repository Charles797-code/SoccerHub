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
  return '/api' + path
}
</script>

<style scoped lang="scss">
.club-banner {
  position: relative;
  height: 200px;
  background: linear-gradient(135deg, #1a56db, #3b82f6);
  border-radius: 12px;
  overflow: hidden;
  margin-bottom: 24px;

  .banner-overlay {
    position: absolute;
    inset: 0;
    background: rgba(0, 0, 0, 0.3);
  }

  .banner-content {
    position: absolute;
    bottom: 24px;
    left: 24px;
    right: 24px;
    display: flex;
    align-items: flex-end;
    gap: 20px;
    color: white;

    .club-logo {
      width: 80px;
      height: 80px;
      border-radius: 50%;
      background: rgba(255, 255, 255, 0.2);
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 32px;
      font-weight: 700;
      flex-shrink: 0;
      overflow: hidden;

      img {
        width: 100%;
        height: 100%;
        object-fit: cover;
      }
    }

    .club-meta {
      h1 {
        margin: 0 0 8px;
        font-size: 24px;
        font-weight: 700;
      }

      .meta-row {
        display: flex;
        align-items: center;
        gap: 12px;
        font-size: 14px;

        .meta-item {
          opacity: 0.9;
        }
      }
    }
  }
}

.player-card {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 14px;
  background: #ffffff;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.2s;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);

  &:hover {
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
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
      font-size: 14px;
      font-weight: 500;
      color: #262626;
    }

    .player-meta {
      display: flex;
      align-items: center;
      gap: 8px;
      margin-top: 4px;

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
      font-size: 18px;
      font-weight: 700;
      color: #1a56db;
    }

    .score-label {
      font-size: 10px;
      color: #a3a3a3;
    }
  }
}

.match-row {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 12px 14px;
  background: #ffffff;
  border-radius: 8px;
  margin-bottom: 8px;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.04);

  .match-date {
    font-size: 13px;
    color: #737373;
    min-width: 60px;
  }

  .match-teams {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 12px;

    .team-name {
      font-size: 14px;
      font-weight: 500;
      color: #262626;
    }

    .match-score {
      font-size: 16px;
      font-weight: 700;
      color: #1a56db;
      min-width: 50px;
      text-align: center;
    }
  }

  .match-status {
    font-size: 12px;
    padding: 3px 10px;
    border-radius: 4px;

    &.live, &.in_progress {
      background: rgba(220, 38, 38, 0.08);
      color: #dc2626;
    }

    &.finished {
      background: rgba(22, 163, 74, 0.08);
      color: #16a34a;
    }

    &.pending {
      background: #f5f5f5;
      color: #a3a3a3;
    }
  }
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;

  .info-item {
    background: #ffffff;
    border-radius: 8px;
    padding: 16px;
    box-shadow: 0 1px 2px rgba(0, 0, 0, 0.04);

    .info-label {
      display: block;
      font-size: 12px;
      color: #a3a3a3;
      margin-bottom: 4px;
    }

    .info-value {
      font-size: 16px;
      font-weight: 500;
      color: #262626;
    }
  }
}

.empty-state {
  text-align: center;
  padding: 40px;
  color: #737373;
  font-size: 14px;
}

.loading-state {
  padding: 24px;
}
</style>
