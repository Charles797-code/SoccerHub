<template>
  <div class="home-page page-container">
    <div class="hero-section">
      <h1>欢迎来到足球社区</h1>
      <p>您的专业足球资讯与社区平台</p>
    </div>

    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-icon">
          <el-icon><Tickets /></el-icon>
        </div>
        <div class="stat-info">
          <span class="stat-value">{{ stats.totalClubs }}</span>
          <span class="stat-label">俱乐部</span>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon">
          <el-icon><User /></el-icon>
        </div>
        <div class="stat-info">
          <span class="stat-value">{{ stats.totalPlayers }}</span>
          <span class="stat-label">球员</span>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon">
          <el-icon><Timer /></el-icon>
        </div>
        <div class="stat-info">
          <span class="stat-value">{{ stats.todayMatches }}</span>
          <span class="stat-label">今日比赛</span>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon">
          <el-icon><TrendCharts /></el-icon>
        </div>
        <div class="stat-info">
          <span class="stat-value">{{ stats.liveMatches }}</span>
          <span class="stat-label">正在直播</span>
        </div>
      </div>
    </div>

    <section class="section">
      <div class="section-header">
        <h2>
          <el-icon><VideoPlay /></el-icon>
          直播比赛
        </h2>
        <router-link to="/matches" class="view-all">查看全部</router-link>
      </div>
      <div class="matches-scroll">
        <div v-for="match in liveMatches" :key="match.matchId" class="match-card">
          <div class="match-league">{{ getLeagueNameCN(match.league) }}</div>
          <div class="match-teams">
            <div class="team">
              <div class="team-logo">{{ getClubName(match.homeClubId)?.charAt(0) }}</div>
              <div class="team-name">{{ getClubName(match.homeClubId) }}</div>
            </div>
            <div class="match-score">
              {{ match.homeScore ?? 0 }} - {{ match.awayScore ?? 0 }}
            </div>
            <div class="team">
              <div class="team-logo">{{ getClubName(match.awayClubId)?.charAt(0) }}</div>
              <div class="team-name">{{ getClubName(match.awayClubId) }}</div>
            </div>
          </div>
          <div class="match-time">{{ match.liveMinute || '进行中' }}</div>
        </div>
        <div v-if="liveMatches.length === 0" class="empty-state">
          暂无直播比赛
        </div>
      </div>
    </section>

    <section class="section">
      <div class="section-header">
        <h2>
          <el-icon><Calendar /></el-icon>
          今日赛事
        </h2>
        <router-link to="/matches" class="view-all">查看全部</router-link>
      </div>
      <div class="matches-grid">
        <div v-for="match in todayMatches" :key="match.matchId" class="match-card" @click="goToMatch(match.matchId)">
          <div class="match-league">{{ getLeagueNameCN(match.league) }}</div>
          <div class="match-teams">
            <div class="team">
              <div class="team-logo">{{ getClubName(match.homeClubId)?.charAt(0) }}</div>
              <div class="team-name">{{ getClubName(match.homeClubId) }}</div>
            </div>
            <div class="match-score">
              <span v-if="match.homeScore !== null">{{ match.homeScore }} - {{ match.awayScore }}</span>
              <span v-else class="vs-text">VS</span>
            </div>
            <div class="team">
              <div class="team-logo">{{ getClubName(match.awayClubId)?.charAt(0) }}</div>
              <div class="team-name">{{ getClubName(match.awayClubId) }}</div>
            </div>
          </div>
          <div class="match-time">{{ formatMatchTime(match.matchTime) }}</div>
          <div class="match-status" :class="match.status?.toLowerCase()">{{ getStatusLabel(match.status) }}</div>
        </div>
        <div v-if="todayMatches.length === 0" class="empty-state">
          今日暂无比赛安排
        </div>
      </div>
    </section>

    <section class="section">
      <div class="section-header">
        <h2>
          <el-icon><Trophy /></el-icon>
          球员评分榜
        </h2>
        <router-link to="/rankings" class="view-all">查看全部</router-link>
      </div>
      <div class="player-list">
        <div v-for="(player, index) in topPlayers" :key="player.playerId" class="player-card" @click="goToPlayer(player.playerId)">
          <div class="rank-badge" :class="'rank-' + (index + 1)">{{ index + 1 }}</div>
          <div class="player-avatar">{{ (player.nameCn || player.name)?.charAt(0) }}</div>
          <div class="player-info">
            <h4>{{ player.nameCn || player.name }}</h4>
            <div class="position">{{ player.clubName || '未知俱乐部' }} · {{ positionMap[player.position] || player.position }}<span v-if="player.birthDate" class="player-age">{{ calcAge(player.birthDate) }}岁</span></div>
          </div>
          <div class="player-score">
            <div class="score-value">{{ Number(player.avgScore).toFixed(2) }}</div>
            <div class="score-label">评分</div>
          </div>
        </div>
      </div>
    </section>

    <section class="section">
      <div class="section-header">
        <h2>
          <el-icon><Medal /></el-icon>
          五大联赛
        </h2>
      </div>
      <div class="leagues-grid">
        <div v-for="league in leagues" :key="league" class="league-card" @click="goToLeague(league)">
          <div class="league-icon">{{ getLeagueDisplay(league) }}</div>
          <div class="league-name">{{ getLeagueNameCN(league) }}</div>
          <div class="league-clubs">{{ getClubCount(league) }} 支球队</div>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { matchApi, playerApi, clubApi } from '@/api'

const router = useRouter()
const stats = ref({ totalClubs: 0, totalPlayers: 0, todayMatches: 0, liveMatches: 0 })
const liveMatches = ref<any[]>([])
const todayMatches = ref<any[]>([])
const topPlayers = ref<any[]>([])
const clubs = ref<any[]>([])
const leagues = ref<string[]>([])

const clubNameMap = ref<Record<number, string>>({})

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

onMounted(async () => {
  try {
    const [clubsRes, playersRes, liveRes, todayRes] = await Promise.all([
      clubApi.list({ page: 1, pageSize: 1 }),
      playerApi.list({ page: 1, pageSize: 1 }),
      matchApi.getLive(),
      matchApi.getToday()
    ])

    stats.value = {
      totalClubs: clubsRes.data.data?.total || 0,
      totalPlayers: playersRes.data.data?.total || 0,
      todayMatches: todayRes.data.data?.length || 0,
      liveMatches: liveRes.data.data?.length || 0
    }

    liveMatches.value = liveRes.data.data || []
    todayMatches.value = todayRes.data.data || []

    const rankingsRes = await playerApi.getRankings({ page: 1, pageSize: 10 })
    topPlayers.value = rankingsRes.data.data?.records || []

    const allClubsRes = await clubApi.list({ page: 1, pageSize: 100 })
    clubs.value = allClubsRes.data.data?.records || []
    clubs.value.forEach((c: any) => {
      clubNameMap.value[c.clubId] = c.shortName || c.name
    })

    const leagueSet = new Set(clubs.value.map((c: any) => c.league))
    leagues.value = Array.from(leagueSet)
  } catch (e) {
    console.error('加载数据失败', e)
  }
})

function getClubName(clubId: number) {
  const name = clubNameMap.value[clubId] || ''
  return name
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

function getClubCount(league: string) {
  return clubs.value.filter((c: any) => c.league === league).length
}

function getLeagueDisplay(league: string) {
  const map: Record<string, string> = {
    'La_Liga': '\u{1F1EA}\u{1F1F8}',
    'Premier_League': '\u{1F1EC}\u{1F1E7}',
    'Bundesliga': '\u{1F1E9}\u{1F1EA}',
    'Serie_A': '\u{1F1EE}\u{1F1F9}',
    'Ligue_1': '\u{1F1EB}\u{1F1F7}'
  }
  const key = league.replace(/\s+/g, '_').replace(/[^a-zA-Z0-9_]/g, '')
  return map[key] || '\u{26BD}'
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

const statusLabelMap: Record<string, string> = {
  PENDING: '未开始',
  IN_PROGRESS: '进行中',
  FINISHED: '已结束',
  LIVE: '直播中'
}

function getStatusLabel(status: string) {
  return statusLabelMap[status] || status
}

function goToMatch(matchId: string) {
  router.push(`/matches`)
}

function goToPlayer(playerId: number) {
  router.push(`/players/${playerId}`)
}

function goToLeague(league: string) {
  router.push(`/clubs?league=${encodeURIComponent(league)}`)
}
</script>

<style scoped lang="scss">
.home-page {
  padding: 24px;
}

.hero-section {
  text-align: center;
  margin-bottom: 32px;
  padding: 40px 0;

  h1 {
    font-size: 28px;
    font-weight: 700;
    margin: 0 0 8px;
    color: #262626;
    letter-spacing: -0.5px;
  }

  p {
    font-size: 15px;
    color: #737373;
    margin: 0;
  }
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 14px;
  margin-bottom: 32px;

  @media (max-width: 900px) {
    grid-template-columns: repeat(2, 1fr);
  }
}

.stat-card {
  background: #ffffff;
  border-radius: 10px;
  padding: 18px;
  display: flex;
  align-items: center;
  gap: 14px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);

  .stat-icon {
    width: 44px;
    height: 44px;
    border-radius: 10px;
    background: rgba(26, 86, 219, 0.1);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 22px;
    color: #1a56db;
  }

  .stat-info {
    display: flex;
    flex-direction: column;

    .stat-value {
      font-size: 24px;
      font-weight: 700;
      color: #262626;
    }

    .stat-label {
      font-size: 12px;
      color: #737373;
    }
  }
}

.section {
  margin-bottom: 32px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 14px;

  h2 {
    margin: 0;
    font-size: 16px;
    font-weight: 600;
    display: flex;
    align-items: center;
    gap: 8px;
    color: #262626;
  }

  .view-all {
    color: #1a56db;
    font-size: 13px;

    &:hover {
      text-decoration: underline;
    }
  }
}

.matches-scroll {
  display: flex;
  gap: 14px;
  overflow-x: auto;
  padding-bottom: 8px;

  &::-webkit-scrollbar {
    height: 4px;
  }

  &::-webkit-scrollbar-thumb {
    background: #e5e5e5;
    border-radius: 2px;
  }
}

.matches-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 14px;
}

.match-card {
  background: #ffffff;
  border-radius: 10px;
  padding: 16px;
  cursor: pointer;
  transition: all 0.2s;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);

  &:hover {
    box-shadow: 0 3px 10px rgba(0, 0, 0, 0.1);
  }

  .match-league {
    font-size: 12px;
    color: #737373;
    margin-bottom: 10px;
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
        width: 40px;
        height: 40px;
        margin: 0 auto 6px;
        border-radius: 50%;
        background: #f5f5f5;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 16px;
        color: #737373;
        overflow: hidden;

        img {
          width: 100%;
          height: 100%;
          object-fit: cover;
        }
      }

      .team-name {
        font-size: 12px;
        font-weight: 500;
        color: #262626;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }
    }

    .match-score {
      font-size: 22px;
      font-weight: 700;
      color: #262626;
      min-width: 44px;
      text-align: center;
    }
  }

  .match-time {
    margin-top: 10px;
    text-align: center;
    font-size: 12px;
    color: #a3a3a3;
  }

  .match-status {
    display: inline-block;
    width: 100%;
    text-align: center;
    margin-top: 6px;
    padding: 3px 10px;
    border-radius: 4px;
    font-size: 11px;

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

.player-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.player-card {
  background: #ffffff;
  border-radius: 10px;
  padding: 12px 14px;
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
  transition: all 0.2s;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);

  &:hover {
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  }

  .rank-badge {
    width: 28px;
    height: 28px;
    border-radius: 6px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: 700;
    font-size: 13px;
    background: #f5f5f5;
    color: #737373;
    flex-shrink: 0;

    &.rank-1 { background: rgba(255, 215, 0, 0.15); color: #d97706; }
    &.rank-2 { background: rgba(156, 163, 175, 0.15); color: #737373; }
    &.rank-3 { background: rgba(180, 83, 9, 0.12); color: #b45309; }
  }

  .player-avatar {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    background: rgba(26, 86, 219, 0.1);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 16px;
    color: #1a56db;
    flex-shrink: 0;
    overflow: hidden;

    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }
  }

  .player-info {
    flex: 1;
    min-width: 0;

    h4 {
      margin: 0;
      font-size: 14px;
      font-weight: 500;
      color: #262626;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    .position {
      font-size: 12px;
      color: #737373;
      margin-top: 2px;

      .player-age {
        margin-left: 6px;
        color: #a3a3a3;
      }
    }
  }

  .player-score {
    text-align: center;

    .score-value {
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

.leagues-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 12px;

  @media (max-width: 1000px) {
    grid-template-columns: repeat(3, 1fr);
  }

  @media (max-width: 600px) {
    grid-template-columns: repeat(2, 1fr);
  }
}

.league-card {
  background: #ffffff;
  border-radius: 10px;
  padding: 18px 14px;
  text-align: center;
  cursor: pointer;
  transition: all 0.2s;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);

  &:hover {
    box-shadow: 0 3px 10px rgba(0, 0, 0, 0.1);
  }

  .league-icon {
    font-size: 28px;
    margin-bottom: 6px;
  }

  .league-name {
    font-size: 13px;
    font-weight: 600;
    color: #262626;
  }

  .league-clubs {
    font-size: 12px;
    color: #a3a3a3;
    margin-top: 3px;
  }
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
