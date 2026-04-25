<template>
  <div class="page-container">
    <div class="page-header">
      <h1>比赛</h1>
      <div class="header-actions">
        <el-select v-model="selectedStatus" placeholder="按状态筛选" clearable size="default"
          style="width: 160px;">
          <el-option v-for="status in matchStatuses" :key="status.value" :label="status.label" :value="status.value" />
        </el-select>
        <el-select v-model="selectedLeague" placeholder="按联赛筛选" clearable size="default"
          style="width: 200px;">
          <el-option v-for="league in leagues" :key="league" :label="getLeagueNameCN(league)" :value="league" />
        </el-select>
      </div>
    </div>

    <div class="matches-grid">
      <div v-for="match in matches" :key="match.matchId" class="match-card" @click="router.push(`/matches/${match.matchId}`)">
        <div class="match-league">{{ getLeagueNameCN(match.league) }}</div>
        <div class="match-teams">
          <div class="team">
            <div class="team-logo">
              <img v-if="getClubLogo(match.homeClubId)" :src="getImageUrl(getClubLogo(match.homeClubId))" alt="logo" />
              <span v-else>{{ getClubName(match.homeClubId)?.charAt(0) }}</span>
            </div>
            <div class="team-name">{{ getClubName(match.homeClubId) }}</div>
          </div>
          <div class="match-center">
            <div class="match-score">
              <span v-if="match.homeScore !== null">{{ match.homeScore }} - {{ match.awayScore }}</span>
              <span v-else class="vs-text">VS</span>
            </div>
            <div class="match-time">{{ formatTime(match.matchTime) }}</div>
          </div>
          <div class="team">
            <div class="team-logo">
              <img v-if="getClubLogo(match.awayClubId)" :src="getImageUrl(getClubLogo(match.awayClubId))" alt="logo" />
              <span v-else>{{ getClubName(match.awayClubId)?.charAt(0) }}</span>
            </div>
            <div class="team-name">{{ getClubName(match.awayClubId) }}</div>
          </div>
        </div>
        <div class="match-footer">
          <span class="match-status" :class="match.status?.toLowerCase()">{{ getStatusLabel(match.status) }}</span>
          <span v-if="match.liveMinute" class="live-minute">{{ match.liveMinute }}</span>
        </div>
      </div>
    </div>

    <div v-if="matches.length === 0" class="empty-state">暂无比赛数据</div>

    <div class="pagination-wrapper">
      <el-pagination v-model:current-page="currentPage" :page-size="pageSize" :total="total"
        layout="prev, pager, next" @current-change="fetchMatches" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { matchApi, clubApi } from '@/api'

const router = useRouter()
const matches = ref<any[]>([])
const leagues = ref<string[]>([])
const selectedStatus = ref('')
const selectedLeague = ref('')
const currentPage = ref(1)
const pageSize = ref(20)
const total = ref(0)

const clubNameMap = ref<Record<number, string>>({})
const clubLogoMap = ref<Record<number, string>>({})

function getClubName(clubId: number) {
  return clubNameMap.value[clubId] || `球队${clubId}`
}

function getClubLogo(clubId: number) {
  return clubLogoMap.value[clubId] || ''
}

function getImageUrl(path: string) {
  if (!path) return ''
  if (path.startsWith('http://') || path.startsWith('https://')) return path
  return '/api' + path
}

const matchStatuses = [
  { value: 'PENDING', label: '未开始' },
  { value: 'IN_PROGRESS', label: '直播中' },
  { value: 'FINISHED', label: '已结束' }
]

const statusLabelMap: Record<string, string> = {
  PENDING: '未开始',
  IN_PROGRESS: '直播中',
  FINISHED: '已结束',
  LIVE: '直播中'
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

function getStatusLabel(status: string) {
  return statusLabelMap[status] || status
}

watch([selectedStatus, selectedLeague], () => {
  currentPage.value = 1
  fetchMatches()
})

onMounted(async () => {
  try {
    const leaguesRes = await clubApi.getLeagues()
    leagues.value = leaguesRes.data.data || []

    const clubsRes = await clubApi.list({ page: 1, pageSize: 100 })
    const allClubs = clubsRes.data.data?.records || []
    allClubs.forEach((c: any) => {
      clubNameMap.value[c.clubId] = c.shortName || c.name
      clubLogoMap.value[c.clubId] = c.logoUrl || ''
    })
  } catch (e) {
    console.error(e)
  }
  fetchMatches()
})

async function fetchMatches() {
  try {
    const res = await matchApi.list({
      page: currentPage.value,
      pageSize: pageSize.value,
      status: selectedStatus.value || undefined,
      league: selectedLeague.value || undefined
    })
    matches.value = res.data.data?.records || []
    total.value = res.data.data?.total || 0
  } catch (e) {
    console.error(e)
  }
}

function formatTime(time: string) {
  if (!time) return ''
  return new Date(time).toLocaleString('zh-CN', {
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
    hour12: false
  })
}
</script>

<style scoped lang="scss">
.matches-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 14px;
}

.match-card {
  background: #ffffff;
  border-radius: 10px;
  padding: 18px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);
  transition: all 0.2s;
  cursor: pointer;

  &:hover {
    box-shadow: 0 3px 10px rgba(0, 0, 0, 0.1);
  }

  .match-league {
    font-size: 12px;
    color: #737373;
    margin-bottom: 14px;
  }

  .match-teams {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;

    .team {
      flex: 1;
      text-align: center;

      .team-logo {
        width: 44px;
        height: 44px;
        margin: 0 auto 8px;
        border-radius: 50%;
        background: #f5f5f5;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 18px;
        color: #737373;
        overflow: hidden;

        img {
          width: 100%;
          height: 100%;
          object-fit: cover;
        }
      }

      .team-name {
        font-size: 13px;
        font-weight: 500;
        color: #262626;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }
    }

    .match-center {
      min-width: 80px;
      text-align: center;

      .match-score {
        font-size: 24px;
        font-weight: 700;
        color: #262626;

        .vs-text {
          color: #a3a3a3;
          font-size: 18px;
        }
      }

      .match-time {
        font-size: 12px;
        color: #a3a3a3;
        margin-top: 4px;
      }
    }
  }

  .match-footer {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 8px;
    margin-top: 14px;

    .match-status {
      font-size: 12px;
      padding: 3px 12px;
      border-radius: 4px;

      &.pending, &.pending {
        background: #f5f5f5;
        color: #a3a3a3;
      }

      &.in_progress, &.live {
        background: rgba(220, 38, 38, 0.08);
        color: #dc2626;
      }

      &.finished {
        background: rgba(22, 163, 74, 0.08);
        color: #16a34a;
      }
    }

    .live-minute {
      font-size: 12px;
      color: #dc2626;
      font-weight: 600;
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
