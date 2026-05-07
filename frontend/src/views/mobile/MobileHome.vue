<template>
  <div class="mobile-home">
    <!-- Live Matches Banner -->
    <div v-if="liveMatches.length > 0" class="live-banner" @click="router.push('/m/matches')">
      <div class="live-badge">
        <span class="live-dot"></span>
        <span>直播中</span>
      </div>
      <div class="live-matches">
        <div v-for="match in liveMatches.slice(0, 3)" :key="match.matchId" class="live-chip">
          <span>{{ getClubName(match.homeClubId) }}</span>
          <span class="score">{{ match.homeScore ?? 0 }} - {{ match.awayScore ?? 0 }}</span>
          <span>{{ getClubName(match.awayClubId) }}</span>
        </div>
      </div>
    </div>

    <!-- Stats Row -->
    <div class="stats-row">
      <div class="stat-item">
        <span class="stat-num">{{ stats.totalClubs }}</span>
        <span class="stat-label">俱乐部</span>
      </div>
      <div class="stat-divider"></div>
      <div class="stat-item">
        <span class="stat-num">{{ stats.totalPlayers }}</span>
        <span class="stat-label">球员</span>
      </div>
      <div class="stat-divider"></div>
      <div class="stat-item">
        <span class="stat-num">{{ stats.todayMatches }}</span>
        <span class="stat-label">今日比赛</span>
      </div>
    </div>

    <!-- Quick Actions -->
    <div class="quick-actions">
      <div class="action-card" @click="router.push('/m/matches')">
        <Timer class="action-icon" />
        <span>赛程</span>
      </div>
      <div class="action-card" @click="router.push('/m/clubs')">
        <Tickets class="action-icon" />
        <span>俱乐部</span>
      </div>
      <div class="action-card" @click="router.push('/m/players')">
        <User class="action-icon" />
        <span>球员</span>
      </div>
      <div class="action-card" @click="router.push('/m/rankings')">
        <TrendCharts class="action-icon" />
        <span>排行</span>
      </div>
    </div>

    <!-- Today's Matches -->
    <section class="section">
      <div class="section-header">
        <h2>今日赛事</h2>
        <span class="more" @click="router.push('/m/matches')">更多</span>
      </div>
      <div class="matches-list" v-if="todayMatches.length > 0">
        <div
          v-for="match in todayMatches"
          :key="match.matchId"
          class="match-item"
          @click="router.push(`/m/matches/${match.matchId}`)"
        >
          <div class="match-time">
            <span class="time">{{ formatTime(match.matchTime) }}</span>
            <span class="status" :class="getStatusClass(match.status)">{{ getStatusLabel(match.status) }}</span>
          </div>
          <div class="match-teams">
            <div class="team">
              <img v-if="getClubLogo(match.homeClubId)" :src="getImageUrl(getClubLogo(match.homeClubId))" :alt="getClubName(match.homeClubId)" />
              <span v-else class="team-initial">{{ getClubName(match.homeClubId)?.charAt(0) }}</span>
              <span class="team-name">{{ getClubName(match.homeClubId) }}</span>
            </div>
            <div class="score-center">
              <span v-if="match.homeScore !== null" class="score">{{ match.homeScore }} - {{ match.awayScore }}</span>
              <span v-else class="vs">VS</span>
              <span v-if="match.liveMinute" class="live-minute">{{ match.liveMinute }}</span>
            </div>
            <div class="team team--away">
              <span class="team-name">{{ getClubName(match.awayClubId) }}</span>
              <img v-if="getClubLogo(match.awayClubId)" :src="getImageUrl(getClubLogo(match.awayClubId))" :alt="getClubName(match.awayClubId)" />
              <span v-else class="team-initial">{{ getClubName(match.awayClubId)?.charAt(0) }}</span>
            </div>
          </div>
        </div>
      </div>
      <div v-else class="empty">
        <Calendar class="empty-icon" />
        <p>今日暂无比赛</p>
      </div>
    </section>

    <!-- Top Players -->
    <section class="section">
      <div class="section-header">
        <h2>球员评分榜</h2>
        <span class="more" @click="router.push('/m/rankings')">更多</span>
      </div>
      <div class="players-list" v-if="topPlayers.length > 0">
        <div
          v-for="(player, index) in topPlayers.slice(0, 10)"
          :key="player.playerId"
          class="player-item"
          @click="router.push(`/m/players/${player.playerId}`)"
        >
          <span class="rank" :class="`rank-${index + 1}`">{{ index + 1 }}</span>
          <img v-if="player.avatarUrl" :src="getImageUrl(player.avatarUrl)" :alt="player.name" class="avatar" />
          <div v-else class="avatar avatar--placeholder">{{ (player.nameCn || player.name)?.charAt(0) }}</div>
          <div class="player-info">
            <span class="name">{{ player.nameCn || player.name }}</span>
            <span class="meta">{{ player.clubName || '未知俱乐部' }} · {{ positionMap[player.position] }}</span>
          </div>
          <span class="score">{{ Number(player.avgScore).toFixed(1) }}</span>
        </div>
      </div>
      <div v-else class="empty">
        <Trophy class="empty-icon" />
        <p>暂无数据</p>
      </div>
    </section>

    <!-- Leagues -->
    <section class="section">
      <div class="section-header">
        <h2>五大联赛</h2>
      </div>
      <div class="leagues-grid">
        <div
          v-for="(league, index) in leagues"
          :key="league"
          class="league-card"
          :style="{ animationDelay: `${index * 50}ms` }"
          @click="goToLeague(league)"
        >
          <div class="league-icon" v-html="getLeagueSVG(league)"></div>
          <span class="league-name">{{ getLeagueShortName(league) }}</span>
          <span class="league-teams">{{ getClubCount(league) }}队</span>
        </div>
      </div>
    </section>

    <!-- News -->
    <section class="section">
      <div class="section-header">
        <h2>足球资讯</h2>
        <span class="more" @click="router.push('/m/news')">更多</span>
      </div>
      <div class="news-list" v-if="topNews.length > 0">
        <div
          v-for="news in topNews"
          :key="news.articleId"
          class="news-item"
          @click="router.push(`/m/news/${news.articleId}`)"
        >
          <img v-if="news.coverImageUrl" :src="getImageUrl(news.coverImageUrl)" :alt="news.title" class="news-img" />
          <div class="news-content">
            <h3 class="news-title">{{ news.title }}</h3>
            <span class="news-meta">{{ news.sourceName || '足球资讯' }} · {{ news.viewCount || 0 }} 阅读</span>
          </div>
        </div>
      </div>
      <div v-else class="empty">
        <Document class="empty-icon" />
        <p>暂无资讯</p>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Timer, Tickets, User, TrendCharts, Calendar, Trophy, Document } from '@element-plus/icons-vue'
import { matchApi, playerApi, clubApi, newsApi } from '@/api'

const router = useRouter()

const stats = ref({ totalClubs: 0, totalPlayers: 0, todayMatches: 0, liveMatches: 0 })
const liveMatches = ref<any[]>([])
const todayMatches = ref<any[]>([])
const topPlayers = ref<any[]>([])
const topNews = ref<any[]>([])
const clubs = ref<any[]>([])
const leagues = ref<string[]>(['La Liga', 'Premier League', 'Bundesliga', 'Serie A', 'Ligue 1'])

const clubNameMap = ref<Record<number, string>>({})
const clubLogoMap = ref<Record<number, string>>({})

const positionMap: Record<string, string> = {
  GK: '门将', DF: '后卫', MF: '中场', FW: '前锋'
}

function getClubName(clubId: number) {
  return clubNameMap.value[clubId] || `球队${clubId}`
}

function getClubLogo(clubId: number) {
  return clubLogoMap.value[clubId] || ''
}

function getImageUrl(url: string) {
  if (!url) return ''
  if (url.startsWith('http://') || url.startsWith('https://')) return url
  if (url.startsWith('/uploads/')) return url
  return '/uploads/' + url.replace(/^\//, '')
}

function formatTime(time: string) {
  if (!time) return ''
  return new Date(time).toLocaleString('zh-CN', {
    hour: '2-digit', minute: '2-digit', hour12: false
  })
}

function getStatusLabel(status: string) {
  const map: Record<string, string> = {
    PENDING: '未开始', IN_PROGRESS: '直播中', FINISHED: '已结束', LIVE: '直播中'
  }
  return map[status] || status
}

function getStatusClass(status: string) {
  const map: Record<string, string> = {
    IN_PROGRESS: 'live', LIVE: 'live', FINISHED: 'finished'
  }
  return map[status] || ''
}

const leagueNameMap: Record<string, string> = {
  'La Liga': '西甲',
  'Premier League': '英超',
  'Bundesliga': '德甲',
  'Serie A': '意甲',
  'Ligue 1': '法甲'
}

const leagueColors: Record<string, string> = {
  'La Liga': '#e8a317',
  'Premier League': '#3d195b',
  'Bundesliga': '#d20515',
  'Serie A': '#024494',
  'Ligue 1': '#9b59b6',
}

function getLeagueShortName(league: string) {
  return leagueNameMap[league] || league
}

function getLeagueColor(league: string) {
  return leagueColors[league] || '#7c3aed'
}

function getLeagueSVG(league: string) {
  const color = getLeagueColor(league)
  return `<svg width="32" height="32" viewBox="0 0 32 32" fill="none">
    <circle cx="16" cy="16" r="14" stroke="${color}" stroke-width="2"/>
    <path d="M16 6L18 12H24L19 16L21 22L16 18L11 22L13 16L8 12H14L16 6Z" fill="${color}" opacity="0.9"/>
  </svg>`
}

function getClubCount(league: string) {
  return clubs.value.filter((c: any) => c.league === league).length
}

function goToLeague(league: string) {
  router.push(`/m/clubs?league=${encodeURIComponent(league)}`)
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
      liveMatches: liveRes.data.data?.length || 0,
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

    // Attach club names to players
    topPlayers.value.forEach((p: any) => {
      p.clubName = clubNameMap.value[p.clubId] || ''
    })

    try {
      const newsRes = await newsApi.list({ page: 1, pageSize: 5 })
      topNews.value = newsRes.data.data?.records || []
    } catch {
      topNews.value = []
    }
  } catch (e) {
    console.error('加载数据失败', e)
  }
})
</script>

<style scoped lang="scss">
@use '@/styles/tokens' as *;

.mobile-home {
  padding: 16px;
  padding-bottom: 80px;
  position: relative;

  // Background effects like PC version
  &::before {
    content: '';
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background:
      radial-gradient(ellipse 80% 50% at 20% -10%, rgba($purple-primary, 0.06) 0%, transparent 60%),
      radial-gradient(ellipse 60% 40% at 80% 110%, rgba($gold-dark, 0.03) 0%, transparent 50%);
    pointer-events: none;
    z-index: -1;
  }
}

// Live Banner
.live-banner {
  background: linear-gradient(135deg, rgba(220, 38, 38, 0.15), rgba(220, 38, 38, 0.05));
  border: 1px solid rgba(220, 38, 38, 0.2);
  border-radius: 12px;
  padding: 12px;
  margin-bottom: 16px;
  cursor: pointer;
}

.live-badge {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  font-weight: 600;
  color: #ef4444;
  margin-bottom: 8px;
}

.live-dot {
  width: 6px;
  height: 6px;
  background: #ef4444;
  border-radius: 50%;
  animation: pulse 1.5s infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.4; }
}

.live-matches {
  display: flex;
  gap: 12px;
  overflow-x: auto;
}

.live-chip {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  color: rgba(255, 255, 255, 0.8);
  white-space: nowrap;

  .score {
    font-weight: 700;
    color: #fff;
  }
}

// Stats Row
.stats-row {
  display: flex;
  justify-content: space-around;
  background: rgba(255, 255, 255, 0.03);
  border-radius: 12px;
  padding: 16px;
  margin-bottom: 16px;
}

.stat-item {
  text-align: center;
}

.stat-num {
  display: block;
  font-size: 24px;
  font-weight: 700;
  background: linear-gradient(135deg, #fbbf24, #f59e0b);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.stat-label {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.5);
}

.stat-divider {
  width: 1px;
  background: rgba(255, 255, 255, 0.1);
}

// Quick Actions
.quick-actions {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
  margin-bottom: 20px;
}

.action-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 16px 8px;
  background: rgba(255, 255, 255, 0.03);
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.2s;

  &:active {
    transform: scale(0.95);
    background: rgba(255, 255, 255, 0.06);
  }

  span {
    font-size: 12px;
    color: rgba(255, 255, 255, 0.7);
  }
}

.action-icon {
  font-size: 24px;
  color: #7c3aed;
}

// Section
.section {
  margin-bottom: 24px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;

  h2 {
    font-size: 16px;
    font-weight: 600;
    color: #fff;
    margin: 0;
  }

  .more {
    font-size: 12px;
    color: #7c3aed;
    cursor: pointer;
  }
}

// Matches
.matches-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.match-item {
  background: rgba(255, 255, 255, 0.03);
  border-radius: 12px;
  padding: 12px;
  cursor: pointer;
  transition: all 0.2s;

  &:active {
    background: rgba(255, 255, 255, 0.06);
  }
}

.match-time {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;

  .time {
    font-size: 12px;
    color: rgba(255, 255, 255, 0.5);
  }

  .status {
    font-size: 10px;
    font-weight: 600;
    padding: 2px 8px;
    border-radius: 10px;
    background: rgba(255, 255, 255, 0.1);
    color: rgba(255, 255, 255, 0.6);

    &.live {
      background: rgba(239, 68, 68, 0.15);
      color: #ef4444;
    }

    &.finished {
      background: rgba(34, 197, 94, 0.15);
      color: #22c55e;
    }
  }
}

.match-teams {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.team {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  max-width: 100px;

  img {
    width: 36px;
    height: 36px;
    border-radius: 50%;
    object-fit: cover;
  }

  .team-initial {
    width: 36px;
    height: 36px;
    border-radius: 50%;
    background: rgba(124, 58, 237, 0.2);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 14px;
    font-weight: 600;
    color: #a78bfa;
  }

  .team-name {
    font-size: 11px;
    color: rgba(255, 255, 255, 0.7);
    text-align: center;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    max-width: 80px;
  }

  &--away {
    .team-name { order: 1; }
    img, .team-initial { order: 2; }
  }
}

.score-center {
  text-align: center;
  flex-shrink: 0;

  .score {
    font-size: 20px;
    font-weight: 700;
    color: #fff;
  }

  .vs {
    font-size: 14px;
    color: rgba(255, 255, 255, 0.3);
  }

  .live-minute {
    display: block;
    font-size: 10px;
    color: #ef4444;
    font-weight: 600;
    margin-top: 2px;
  }
}

// Players
.players-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.player-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px;
  background: rgba(255, 255, 255, 0.03);
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.2s;

  &:active {
    background: rgba(255, 255, 255, 0.06);
  }
}

.rank {
  width: 24px;
  height: 24px;
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: 700;
  background: rgba(255, 255, 255, 0.1);
  color: rgba(255, 255, 255, 0.6);
  flex-shrink: 0;

  &.rank-1 {
    background: rgba(251, 191, 36, 0.2);
    color: #fbbf24;
  }
  &.rank-2 {
    background: rgba(192, 192, 192, 0.2);
    color: #c0c0c0;
  }
  &.rank-3 {
    background: rgba(180, 83, 9, 0.2);
    color: #d97706;
  }
}

.avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
  flex-shrink: 0;

  &--placeholder {
    background: rgba(124, 58, 237, 0.2);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 16px;
    font-weight: 600;
    color: #a78bfa;
  }
}

.player-info {
  flex: 1;
  min-width: 0;

  .name {
    display: block;
    font-size: 14px;
    font-weight: 500;
    color: #fff;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .meta {
    font-size: 11px;
    color: rgba(255, 255, 255, 0.5);
  }
}

.score {
  font-size: 18px;
  font-weight: 700;
  background: linear-gradient(135deg, #fbbf24, #f59e0b);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  flex-shrink: 0;
}

// News
.news-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.news-item {
  display: flex;
  gap: 12px;
  padding: 10px;
  background: rgba(255, 255, 255, 0.03);
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.2s;

  &:active {
    background: rgba(255, 255, 255, 0.06);
  }
}

.news-img {
  width: 80px;
  height: 60px;
  border-radius: 8px;
  object-fit: cover;
  flex-shrink: 0;
}

.news-content {
  flex: 1;
  min-width: 0;
}

.news-title {
  font-size: 14px;
  font-weight: 500;
  color: #fff;
  margin: 0 0 6px;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  line-height: 1.4;
}

.news-meta {
  font-size: 11px;
  color: rgba(255, 255, 255, 0.4);
}

// Empty
.empty {
  text-align: center;
  padding: 32px 16px;
  color: rgba(255, 255, 255, 0.4);

  .empty-icon {
    font-size: 32px;
    margin-bottom: 8px;
    opacity: 0.5;
  }

  p {
    margin: 0;
    font-size: 14px;
  }
}

// Leagues
.leagues-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 8px;
}

.league-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  padding: 12px 4px;
  background: rgba(255, 255, 255, 0.03);
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.2s;

  &:active {
    transform: scale(0.95);
    background: rgba(255, 255, 255, 0.06);
  }
}

.league-icon {
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  filter: drop-shadow(0 0 6px rgba(124, 58, 237, 0.3));
}

.league-name {
  font-size: 11px;
  font-weight: 600;
  color: #fff;
}

.league-teams {
  font-size: 9px;
  color: rgba(255, 255, 255, 0.4);
}

@media (max-width: 360px) {
  .leagues-grid {
    grid-template-columns: repeat(3, 1fr);
  }
}
</style>
