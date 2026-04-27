<template>
  <div class="home-page page-container">
    <div class="hero-section">
      <h1 class="hero-title">
        欢迎来到 <span class="logo-text">Soccer<span class="logo-highlight">Hub</span></span>
      </h1>
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
              <div class="team-logo">
                <img v-if="getClubLogo(match.homeClubId)" :src="getImageUrl(getClubLogo(match.homeClubId))" alt="logo" />
                <span v-else>{{ getClubName(match.homeClubId)?.charAt(0) }}</span>
              </div>
              <div class="team-name">{{ getClubName(match.homeClubId) }}</div>
            </div>
            <div class="match-score">
              {{ match.homeScore ?? 0 }} - {{ match.awayScore ?? 0 }}
            </div>
            <div class="team">
              <div class="team-logo">
                <img v-if="getClubLogo(match.awayClubId)" :src="getImageUrl(getClubLogo(match.awayClubId))" alt="logo" />
                <span v-else>{{ getClubName(match.awayClubId)?.charAt(0) }}</span>
              </div>
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
              <div class="team-logo">
                <img v-if="getClubLogo(match.homeClubId)" :src="getImageUrl(getClubLogo(match.homeClubId))" alt="logo" />
                <span v-else>{{ getClubName(match.homeClubId)?.charAt(0) }}</span>
              </div>
              <div class="team-name">{{ getClubName(match.homeClubId) }}</div>
            </div>
            <div class="match-score">
              <span v-if="match.homeScore !== null">{{ match.homeScore }} - {{ match.awayScore }}</span>
              <span v-else class="vs-text">VS</span>
            </div>
            <div class="team">
              <div class="team-logo">
                <img v-if="getClubLogo(match.awayClubId)" :src="getImageUrl(getClubLogo(match.awayClubId))" alt="logo" />
                <span v-else>{{ getClubName(match.awayClubId)?.charAt(0) }}</span>
              </div>
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
          <div class="player-avatar">
            <img v-if="player.avatarUrl" :src="getImageUrl(player.avatarUrl)" alt="头像" />
            <span v-else>{{ (player.nameCn || player.name)?.charAt(0) }}</span>
          </div>
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
          <el-icon><Document /></el-icon>
          足球头条
        </h2>
        <router-link to="/news" class="view-all">更多新闻</router-link>
      </div>
      <div class="news-grid">
        <div v-for="news in topNews" :key="news.articleId" class="news-card" @click="router.push(`/news/${news.articleId}`)">
          <div class="news-cover" v-if="news.coverImageUrl">
            <img :src="getImageUrl(news.coverImageUrl)" :alt="news.title" />
          </div>
          <div class="news-cover news-cover-placeholder" v-else>
            <el-icon :size="24"><Document /></el-icon>
          </div>
          <div class="news-info">
            <h4>{{ news.title }}</h4>
            <div class="news-meta">
              <span v-if="news.sourceName" class="news-source">{{ news.sourceName }}</span>
              <span>{{ news.viewCount || 0 }} 阅读</span>
            </div>
          </div>
        </div>
        <div v-if="topNews.length === 0" class="empty-state">
          暂无新闻
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
import { matchApi, playerApi, clubApi, newsApi } from '@/api'

const router = useRouter()
const stats = ref({ totalClubs: 0, totalPlayers: 0, todayMatches: 0, liveMatches: 0 })
const liveMatches = ref<any[]>([])
const todayMatches = ref<any[]>([])
const topPlayers = ref<any[]>([])
const topNews = ref<any[]>([])
const clubs = ref<any[]>([])
const leagues = ref<string[]>([])

const clubNameMap = ref<Record<number, string>>({})
const clubLogoMap = ref<Record<number, string>>({})

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
      clubLogoMap.value[c.clubId] = c.logoUrl || c.logo || ''
    })

    const leagueSet = new Set(clubs.value.map((c: any) => c.league))
    leagues.value = Array.from(leagueSet)

    try {
      const newsRes = await newsApi.list({ page: 1, pageSize: 4 })
      topNews.value = newsRes.data.data?.records || []
    } catch {
      topNews.value = []
    }
  } catch (e) {
    console.error('加载数据失败', e)
  }
})

function getClubName(clubId: number) {
  const name = clubNameMap.value[clubId] || ''
  return name
}

function getClubLogo(clubId: number) {
  return clubLogoMap.value[clubId] || ''
}

function getImageUrl(url: string) {
  if (!url) return ''
  if (url.startsWith('http://') || url.startsWith('https://')) return url
  return '/api' + url
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
  IN_PROGRESS: '直播中',
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
  padding: 48px 0;
  background: linear-gradient(180deg, rgba(37, 99, 235, 0.03) 0%, transparent 100%);
  border-radius: 24px;

  .hero-title {
    font-size: 32px;
    font-weight: 800;
    margin: 0 0 12px;
    color: var(--el-text-color-primary);
    letter-spacing: -0.5px;
  }

  .logo-text {
    font-family: 'Inter', 'Segoe UI', sans-serif;
    font-weight: 800;
    color: var(--el-color-primary);
  }

  .logo-highlight {
    background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
  }

  p {
    font-size: 16px;
    color: var(--el-text-color-regular);
    margin: 0;
    font-weight: 500;
  }
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 36px;

  @media (max-width: 900px) {
    grid-template-columns: repeat(2, 1fr);
  }
}

.stat-card {
  background: var(--el-bg-color-overlay);
  border-radius: 16px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 16px;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -2px rgba(0, 0, 0, 0.05);
  border: 1px solid var(--el-border-color-light);
  transition: all 0.3s ease;

  &:hover {
    transform: translateY(-4px);
    box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.05);
    border-color: var(--el-border-color);
  }

  .stat-icon {
    width: 52px;
    height: 52px;
    border-radius: 14px;
    background: linear-gradient(135deg, var(--el-color-primary-light-9) 0%, var(--el-color-primary-light-7) 100%);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 24px;
    color: var(--el-color-primary);
    box-shadow: inset 0 2px 4px rgba(255, 255, 255, 0.5);
  }

  .stat-info {
    display: flex;
    flex-direction: column;

    .stat-value {
      font-size: 26px;
      font-weight: 800;
      color: var(--el-text-color-primary);
      letter-spacing: -0.5px;
    }

    .stat-label {
      font-size: 13px;
      color: var(--el-text-color-regular);
      font-weight: 500;
    }
  }
}

.section {
  margin-bottom: 36px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;

  h2 {
    margin: 0;
    font-size: 18px;
    font-weight: 700;
    display: flex;
    align-items: center;
    gap: 10px;
    color: var(--el-text-color-primary);
    
    .el-icon {
      color: var(--el-color-primary);
      background: var(--el-color-primary-light-9);
      padding: 6px;
      border-radius: 8px;
    }
  }

  .view-all {
    color: var(--el-color-primary);
    font-size: 14px;
    font-weight: 600;

    &:hover {
      color: var(--el-color-primary-light-3);
    }
  }
}

.matches-scroll {
  display: flex;
  gap: 20px;
  overflow-x: auto;
  padding-bottom: 12px;

  &::-webkit-scrollbar {
    height: 6px;
  }

  &::-webkit-scrollbar-thumb {
    background: var(--el-border-color);
    border-radius: 3px;
  }
}

.matches-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 20px;
}

.match-card {
  background: var(--el-bg-color-overlay);
  border-radius: 16px;
  padding: 20px;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
  border: 1px solid var(--el-border-color-light);

  &:hover {
    transform: translateY(-4px);
    box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.05);
    border-color: var(--el-border-color);
  }

  .match-league {
    font-size: 12px;
    color: var(--el-color-primary-dark-2);
    margin-bottom: 16px;
    font-weight: 600;
    display: inline-block;
    padding: 4px 10px;
    background: var(--el-color-primary-light-9);
    border-radius: 6px;
  }

  .match-teams {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 16px;

    .team {
      flex: 1;
      text-align: center;

      .team-logo {
        width: 48px;
        height: 48px;
        margin: 0 auto 10px;
        border-radius: 50%;
        background: var(--el-bg-color);
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 20px;
        color: var(--el-text-color-regular);
        overflow: hidden;
        border: 1px solid var(--el-border-color-light);
        box-shadow: 0 2px 4px rgba(0,0,0,0.02);

        img {
          width: 100%;
          height: 100%;
          object-fit: cover;
        }
      }

      .team-name {
        font-size: 13px;
        font-weight: 600;
        color: var(--el-text-color-primary);
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }
    }

    .match-score {
      font-size: 26px;
      font-weight: 800;
      color: var(--el-text-color-primary);
      min-width: 60px;
      text-align: center;
    }
  }

  .match-time {
    margin-top: 16px;
    text-align: center;
    font-size: 13px;
    color: var(--el-text-color-secondary);
  }

  .match-status {
    display: inline-block;
    width: 100%;
    text-align: center;
    margin-top: 10px;
    padding: 4px 12px;
    border-radius: 6px;
    font-size: 12px;
    font-weight: 600;

    &.live, &.in_progress {
      background: #fef2f2;
      color: #ef4444;
      animation: pulse 2s infinite;
    }

    &.finished {
      background: #f0fdf4;
      color: #10b981;
    }

    &.pending {
      background: var(--el-bg-color);
      color: var(--el-text-color-regular);
    }
  }
}

.player-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.player-card {
  background: var(--el-bg-color-overlay);
  border-radius: 16px;
  padding: 16px 20px;
  display: flex;
  align-items: center;
  gap: 16px;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 2px 4px -1px rgba(0, 0, 0, 0.05);
  border: 1px solid var(--el-border-color-light);

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.05);
    border-color: var(--el-border-color);
  }

  .rank-badge {
    width: 32px;
    height: 32px;
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: 800;
    font-size: 14px;
    background: var(--el-bg-color);
    color: var(--el-text-color-regular);
    flex-shrink: 0;

    &.rank-1 { background: linear-gradient(135deg, #fef08a 0%, #eab308 100%); color: #713f12; box-shadow: 0 2px 4px rgba(234, 179, 8, 0.2); }
    &.rank-2 { background: linear-gradient(135deg, #e2e8f0 0%, #94a3b8 100%); color: #1e293b; box-shadow: 0 2px 4px rgba(148, 163, 184, 0.2); }
    &.rank-3 { background: linear-gradient(135deg, #fed7aa 0%, #f97316 100%); color: #7c2d12; box-shadow: 0 2px 4px rgba(249, 115, 22, 0.2); }
  }

  .player-avatar {
    width: 48px;
    height: 48px;
    border-radius: 50%;
    background: linear-gradient(135deg, var(--el-color-primary-light-5), var(--el-color-primary));
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 18px;
    font-weight: 700;
    color: white;
    flex-shrink: 0;
    overflow: hidden;
    box-shadow: 0 2px 6px rgba(37, 99, 235, 0.2);

    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
      display: block;
    }
  }

  .player-info {
    flex: 1;
    min-width: 0;

    h4 {
      margin: 0;
      font-size: 16px;
      font-weight: 600;
      color: var(--el-text-color-primary);
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    .position {
      font-size: 13px;
      color: var(--el-text-color-regular);
      margin-top: 4px;

      .player-age {
        margin-left: 8px;
        color: var(--el-text-color-secondary);
      }
    }
  }

  .player-score {
    text-align: center;

    .score-value {
      font-size: 22px;
      font-weight: 800;
      color: var(--el-color-primary);
    }

    .score-label {
      font-size: 11px;
      color: var(--el-text-color-secondary);
      font-weight: 500;
    }
  }
}

.news-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
}

.news-card {
  display: flex;
  gap: 16px;
  padding: 16px;
  background: var(--el-bg-color-overlay);
  border-radius: 16px;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 2px 4px -1px rgba(0, 0, 0, 0.05);
  border: 1px solid var(--el-border-color-light);

  &:hover {
    transform: translateY(-4px);
    box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.05);
    border-color: var(--el-border-color);
  }

  .news-cover {
    width: 120px;
    height: 80px;
    border-radius: 10px;
    overflow: hidden;
    flex-shrink: 0;
    border: 1px solid var(--el-border-color-light);

    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
      transition: transform 0.3s ease;
    }
    
    &:hover img {
      transform: scale(1.05);
    }

    &.news-cover-placeholder {
      background: var(--el-color-primary-light-9);
      display: flex;
      align-items: center;
      justify-content: center;
      color: var(--el-color-primary-light-5);
    }
  }

  .news-info {
    flex: 1;
    min-width: 0;
    display: flex;
    flex-direction: column;
    justify-content: space-between;

    h4 {
      margin: 0 0 8px;
      font-size: 15px;
      font-weight: 600;
      color: var(--el-text-color-primary);
      line-height: 1.5;
      display: -webkit-box;
      -webkit-line-clamp: 2;
      -webkit-box-orient: vertical;
      overflow: hidden;
    }

    .news-meta {
      display: flex;
      align-items: center;
      gap: 10px;
      font-size: 12px;
      color: var(--el-text-color-secondary);

      .news-source {
        background: var(--el-color-primary-light-9);
        color: var(--el-color-primary-dark-2);
        padding: 2px 8px;
        border-radius: 4px;
        font-weight: 500;
      }
    }
  }
}

.leagues-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 16px;

  @media (max-width: 1000px) {
    grid-template-columns: repeat(3, 1fr);
  }

  @media (max-width: 600px) {
    grid-template-columns: repeat(2, 1fr);
  }
}

.league-card {
  background: var(--el-bg-color-overlay);
  border-radius: 16px;
  padding: 24px 16px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 2px 4px -1px rgba(0, 0, 0, 0.05);
  border: 1px solid var(--el-border-color-light);

  &:hover {
    transform: translateY(-4px);
    box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.05);
    border-color: var(--el-color-primary-light-5);
  }

  .league-icon {
    font-size: 36px;
    margin-bottom: 12px;
    transition: transform 0.3s ease;
  }
  
  &:hover .league-icon {
    transform: scale(1.1);
  }

  .league-name {
    font-size: 14px;
    font-weight: 700;
    color: var(--el-text-color-primary);
  }

  .league-clubs {
    font-size: 12px;
    color: var(--el-text-color-secondary);
    margin-top: 6px;
    font-weight: 500;
  }
}

.empty-state {
  text-align: center;
  padding: 48px;
  color: var(--el-text-color-secondary);
  font-size: 15px;
  font-weight: 500;
  background: var(--el-bg-color-overlay);
  border-radius: 16px;
  border: 1px dashed var(--el-border-color);
}
</style>
