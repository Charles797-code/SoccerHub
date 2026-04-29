<template>
  <div class="home-page">
    <!-- Hero Section -->
    <section class="hero-section">
      <div class="hero-bg">
        <div class="hero-glow hero-glow--left"></div>
        <div class="hero-glow hero-glow--right"></div>
        <div class="hero-grid"></div>
      </div>
      <div class="hero-content">
        <div class="hero-eyebrow">
          <span class="eyebrow-dot"></span>
          <span>足球资讯与社区平台</span>
        </div>
        <h1 class="hero-title">
          <span class="title-line">欢迎来到</span>
          <span class="title-brand">Soccer<span class="brand-accent">Hub</span></span>
        </h1>
        <p class="hero-subtitle">五大联赛 · 实时比分 · 球员评分 · 球迷社区</p>
        <div class="hero-actions">
          <button class="hero-btn hero-btn--primary" @click="router.push('/matches')">
            <el-icon><Timer /></el-icon>
            查看比赛
          </button>
          <button class="hero-btn hero-btn--ghost" @click="router.push('/clubs')">
            <el-icon><Tickets /></el-icon>
            浏览俱乐部
          </button>
        </div>
      </div>

      <!-- Live Matches Strip -->
      <div v-if="liveMatches.length > 0" class="live-strip">
        <div class="live-strip-inner">
          <div class="live-badge">
            <span class="live-badge-dot"></span>
            <span>直播中</span>
          </div>
          <div class="live-matches-scroll">
            <div
              v-for="match in liveMatches"
              :key="match.matchId"
              class="live-match-chip"
              @click="router.push(`/matches/${match.matchId}`)"
            >
              <span class="chip-home">{{ getClubName(match.homeClubId) }}</span>
              <span class="chip-score">{{ match.homeScore ?? 0 }} - {{ match.awayScore ?? 0 }}</span>
              <span class="chip-away">{{ getClubName(match.awayClubId) }}</span>
              <span class="chip-minute" v-if="match.liveMinute">{{ match.liveMinute }}</span>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Stats Row -->
    <section class="stats-section">
      <div class="stats-grid">
        <div
          v-for="(stat, index) in statsData"
          :key="stat.label"
          class="stat-card"
          :style="{ animationDelay: `${index * 80}ms` }"
        >
          <div class="stat-icon-wrap">
            <el-icon class="stat-icon">
              <component :is="stat.icon" />
            </el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value" ref="statValueRefs">{{ stat.value }}</div>
            <div class="stat-label">{{ stat.label }}</div>
          </div>
        </div>
      </div>
    </section>

    <!-- Today's Matches -->
    <section class="section">
      <div class="section-header">
        <h2>
          <el-icon class="section-icon section-icon--gold"><Calendar /></el-icon>
          今日赛事
        </h2>
        <router-link to="/matches" class="view-all">
          查看全部
          <el-icon class="arrow-icon"><ArrowRight /></el-icon>
        </router-link>
      </div>
      <div class="matches-grid" v-if="todayMatches.length > 0">
        <div
          v-for="(match, index) in todayMatches"
          :key="match.matchId"
          class="match-card"
          :style="{ animationDelay: `${index * 60}ms` }"
          @click="goToMatch(match.matchId)"
        >
          <!-- League Tag -->
          <div class="match-card__league">
            <span class="league-dot" :style="{ background: getLeagueColor(match.league) }"></span>
            <span class="league-name">{{ getLeagueNameCN(match.league) }}</span>
          </div>

          <!-- Teams Row -->
          <div class="match-card__teams">
            <div class="match-team match-team--home">
              <div class="team-logo-wrap">
                <img
                  v-if="getClubLogo(match.homeClubId)"
                  :src="getImageUrl(getClubLogo(match.homeClubId))"
                  :alt="getClubName(match.homeClubId)"
                />
                <span v-else class="team-initial">{{ getClubName(match.homeClubId)?.charAt(0) }}</span>
              </div>
              <span class="team-name">{{ getClubName(match.homeClubId) }}</span>
            </div>

            <div class="match-card__center">
              <div class="score-display" :class="{ 'score-display--live': match.status === 'IN_PROGRESS' || match.status === 'LIVE' }">
                <span v-if="match.homeScore !== null" class="score-num">{{ match.homeScore }}</span>
                <span v-else class="score-vs">VS</span>
                <span class="score-sep" v-if="match.homeScore !== null">-</span>
                <span v-if="match.awayScore !== null" class="score-num">{{ match.awayScore }}</span>
              </div>
              <div class="match-card__time">
                <span v-if="match.liveMinute" class="live-minute">{{ match.liveMinute }}</span>
                <span v-else class="scheduled-time">{{ formatMatchTime(match.matchTime) }}</span>
              </div>
            </div>

            <div class="match-team match-team--away">
              <div class="team-logo-wrap">
                <img
                  v-if="getClubLogo(match.awayClubId)"
                  :src="getImageUrl(getClubLogo(match.awayClubId))"
                  :alt="getClubName(match.awayClubId)"
                />
                <span v-else class="team-initial">{{ getClubName(match.awayClubId)?.charAt(0) }}</span>
              </div>
              <span class="team-name">{{ getClubName(match.awayClubId) }}</span>
            </div>
          </div>

          <!-- Status -->
          <div class="match-card__footer">
            <span class="status-badge" :class="getStatusClass(match.status)">
              {{ getStatusLabel(match.status) }}
            </span>
          </div>
        </div>
      </div>
      <div v-else class="empty-state">
        <div class="empty-icon">
          <el-icon><Calendar /></el-icon>
        </div>
        <p>今日暂无比赛安排</p>
      </div>
    </section>

    <!-- Top Players -->
    <section class="section">
      <div class="section-header">
        <h2>
          <el-icon class="section-icon section-icon--gold"><Trophy /></el-icon>
          球员评分榜
        </h2>
        <router-link to="/rankings" class="view-all">
          查看全部
          <el-icon class="arrow-icon"><ArrowRight /></el-icon>
        </router-link>
      </div>
      <div class="players-list">
        <div
          v-for="(player, index) in topPlayers"
          :key="player.playerId"
          class="player-card"
          :style="{ animationDelay: `${index * 50}ms` }"
          @click="goToPlayer(player.playerId)"
        >
          <!-- Rank -->
          <div class="player-rank" :class="`rank-${index + 1}`">
            <span v-if="index < 3" class="rank-medal">
              <el-icon><Medal /></el-icon>
            </span>
            <span v-else class="rank-num">{{ index + 1 }}</span>
          </div>

          <!-- Avatar -->
          <div class="player-avatar-wrap">
            <img
              v-if="player.avatarUrl"
              :src="getImageUrl(player.avatarUrl)"
              :alt="player.nameCn || player.name"
            />
            <span v-else class="player-initial">
              {{ (player.nameCn || player.name)?.charAt(0) }}
            </span>
          </div>

          <!-- Info -->
          <div class="player-info">
            <div class="player-name">{{ player.nameCn || player.name }}</div>
            <div class="player-meta">
              <span class="player-club">{{ player.clubName || '未知俱乐部' }}</span>
              <span class="meta-sep">·</span>
              <span class="player-position">{{ positionMap[player.position] || player.position }}</span>
              <span v-if="player.birthDate" class="player-age">{{ calcAge(player.birthDate) }}岁</span>
            </div>
          </div>

          <!-- Score -->
          <div class="player-score-wrap">
            <div class="player-score-value">{{ Number(player.avgScore).toFixed(1) }}</div>
            <div class="player-score-label">评分</div>
          </div>
        </div>
        <div v-if="topPlayers.length === 0" class="empty-state">
          <div class="empty-icon"><el-icon><Trophy /></el-icon></div>
          <p>暂无球员数据</p>
        </div>
      </div>
    </section>

    <!-- News Section -->
    <section class="section">
      <div class="section-header">
        <h2>
          <el-icon class="section-icon section-icon--gold"><Document /></el-icon>
          足球资讯
        </h2>
        <router-link to="/news" class="view-all">
          更多
          <el-icon class="arrow-icon"><ArrowRight /></el-icon>
        </router-link>
      </div>
      <div class="news-grid" v-if="topNews.length > 0">
        <div
          v-for="(news, index) in topNews"
          :key="news.articleId"
          class="news-card"
          :style="{ animationDelay: `${index * 60}ms` }"
          @click="router.push(`/news/${news.articleId}`)"
        >
          <div class="news-card__image" v-if="news.coverImageUrl">
            <img :src="getImageUrl(news.coverImageUrl)" :alt="news.title" />
            <div class="news-card__overlay"></div>
          </div>
          <div class="news-card__image news-card__image--placeholder" v-else>
            <el-icon><Document /></el-icon>
          </div>
          <div class="news-card__content">
            <div class="news-card__meta">
              <span v-if="news.sourceName" class="news-source">{{ news.sourceName }}</span>
              <span class="news-views">{{ news.viewCount || 0 }} 阅读</span>
            </div>
            <h3 class="news-title">{{ news.title }}</h3>
          </div>
        </div>
      </div>
      <div v-else class="empty-state">
        <div class="empty-icon"><el-icon><Document /></el-icon></div>
        <p>暂无资讯</p>
      </div>
    </section>

    <!-- Leagues -->
    <section class="section">
      <div class="section-header">
        <h2>
          <el-icon class="section-icon section-icon--gold"><Medal /></el-icon>
          五大联赛
        </h2>
      </div>
      <div class="leagues-grid">
        <div
          v-for="(league, index) in leagues"
          :key="league"
          class="league-card"
          :style="{ animationDelay: `${index * 50}ms` }"
          @click="goToLeague(league)"
        >
          <div class="league-card__bg"></div>
          <div class="league-card__icon" v-html="getLeagueSVG(league)"></div>
          <div class="league-card__info">
            <div class="league-card__name">{{ getLeagueShortName(league) }}</div>
            <div class="league-card__teams">{{ getClubCount(league) }} 支球队</div>
          </div>
          <div class="league-card__action">
            <el-icon><ArrowRight /></el-icon>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, markRaw } from 'vue'
import { useRouter } from 'vue-router'
import {
  Timer, Tickets, Trophy, Calendar, Document, Medal,
  ArrowRight, User, TrendCharts
} from '@element-plus/icons-vue'
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
  GK: '门将', DF: '后卫', MF: '中场', FW: '前锋'
}

const leagueNameMap: Record<string, string> = {
  'La Liga': '西班牙足球甲级联赛',
  'Premier League': '英格兰足球超级联赛',
  'Bundesliga': '德国足球甲级联赛',
  'Serie A': '意大利足球甲级联赛',
  'Ligue 1': '法国足球甲级联赛'
}

const leagueColors: Record<string, string> = {
  'La Liga': '#e8a317',
  'Premier League': '#3d195b',
  'Bundesliga': '#d20515',
  'Serie A': '#024494',
  'Ligue 1': '#dda0dd',
}

const statsData = computed(() => [
  { label: '俱乐部', value: stats.value.totalClubs, icon: markRaw(Tickets) },
  { label: '球员', value: stats.value.totalPlayers, icon: markRaw(User) },
  { label: '今日比赛', value: stats.value.todayMatches, icon: markRaw(Calendar) },
  { label: '正在直播', value: stats.value.liveMatches, icon: markRaw(Timer) },
])

function getLeagueNameCN(league: string) {
  return leagueNameMap[league] || league
}

function getLeagueShortName(league: string) {
  const short: Record<string, string> = {
    'La Liga': '西甲',
    'Premier League': '英超',
    'Bundesliga': '德甲',
    'Serie A': '意甲',
    'Ligue 1': '法甲',
  }
  return short[league] || league
}

function getLeagueColor(league: string) {
  return leagueColors[league] || '#7c3aed'
}

function getLeagueSVG(league: string) {
  const svgs: Record<string, string> = {
    'La Liga': `<svg width="40" height="40" viewBox="0 0 40 40" fill="none"><circle cx="20" cy="20" r="18" stroke="#e8a317" stroke-width="2"/><path d="M20 8L22 16H30L24 21L26 29L20 24L14 29L16 21L10 16H18L20 8Z" fill="#e8a317" opacity="0.9"/></svg>`,
    'Premier League': `<svg width="40" height="40" viewBox="0 0 40 40" fill="none"><circle cx="20" cy="20" r="18" stroke="#e8b44e" stroke-width="2"/><path d="M13 12H27L25 20L27 28H13L15 20L13 12Z" fill="#e8b44e" opacity="0.9"/></svg>`,
    'Bundesliga': `<svg width="40" height="40" viewBox="0 0 40 40" fill="none"><circle cx="20" cy="20" r="18" stroke="#d20515" stroke-width="2"/><circle cx="20" cy="20" r="6" fill="#d20515" opacity="0.9"/></svg>`,
    'Serie A': `<svg width="40" height="40" viewBox="0 0 40 40" fill="none"><circle cx="20" cy="20" r="18" stroke="#024494" stroke-width="2"/><path d="M14 12L26 12L26 28L14 28Z" fill="#024494" opacity="0.9"/></svg>`,
    'Ligue 1': `<svg width="40" height="40" viewBox="0 0 40 40" fill="none"><circle cx="20" cy="20" r="18" stroke="#dda0dd" stroke-width="2"/><path d="M20 10L24 16L31 17L26 22L27 29L20 26L13 29L14 22L9 17L16 16Z" fill="#dda0dd" opacity="0.9"/></svg>`,
  }
  return svgs[league] || `<svg width="40" height="40" viewBox="0 0 40 40" fill="none"><circle cx="20" cy="20" r="18" stroke="#7c3aed" stroke-width="2"/></svg>`
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

function getStatusLabel(status: string) {
  const map: Record<string, string> = {
    PENDING: '未开始', IN_PROGRESS: '直播中', FINISHED: '已结束', LIVE: '直播中'
  }
  return map[status] || status
}

function getStatusClass(status: string) {
  const map: Record<string, string> = {
    PENDING: 'status--pending',
    IN_PROGRESS: 'status--live',
    LIVE: 'status--live',
    FINISHED: 'status--finished',
  }
  return map[status] || ''
}

function formatMatchTime(time: string) {
  if (!time) return ''
  return new Date(time).toLocaleString('zh-CN', {
    month: 'short', day: 'numeric',
    hour: '2-digit', minute: '2-digit', hour12: false
  })
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

function goToMatch(matchId: string) {
  router.push(`/matches/${matchId}`)
}

function goToPlayer(playerId: number) {
  router.push(`/players/${playerId}`)
}

function goToLeague(league: string) {
  router.push(`/clubs?league=${encodeURIComponent(league)}`)
}
</script>

<style scoped lang="scss">
@use '@/styles/tokens' as *;

// --------------------------------------------------------------------------
// Home Page
// --------------------------------------------------------------------------

.home-page {
  padding: 0 0 $space-12;
}

// --------------------------------------------------------------------------
// Hero Section
// --------------------------------------------------------------------------

.hero-section {
  position: relative;
  padding: $space-12 $space-6 $space-8;
  overflow: hidden;
}

.hero-bg {
  position: absolute;
  inset: 0;
  z-index: 0;
}

.hero-glow {
  position: absolute;
  width: 500px;
  height: 500px;
  border-radius: $radius-full;
  filter: blur(100px);
  opacity: 0.15;

  &--left {
    top: -150px;
    left: -100px;
    background: $purple-primary;
  }

  &--right {
    top: -100px;
    right: -100px;
    background: $gold-dark;
  }
}

.hero-grid {
  position: absolute;
  inset: 0;
  background-image:
    linear-gradient(rgba($purple-primary, 0.03) 1px, transparent 1px),
    linear-gradient(90deg, rgba($purple-primary, 0.03) 1px, transparent 1px);
  background-size: 40px 40px;
  mask-image: radial-gradient(ellipse 80% 60% at 50% 0%, black 40%, transparent 100%);
}

.hero-content {
  position: relative;
  z-index: 1;
  max-width: $content-max-width;
  margin: 0 auto;
  text-align: center;
  animation: fadeIn 600ms $ease-out both;
}

.hero-eyebrow {
  display: inline-flex;
  align-items: center;
  gap: $space-2;
  margin-bottom: $space-4;
  padding: $space-1 $space-4;
  background: rgba($purple-primary, 0.1);
  border: 1px solid rgba($purple-primary, 0.25);
  border-radius: $radius-full;
  font-size: $font-size-sm;
  color: $purple-light;
  font-weight: $font-weight-medium;
  letter-spacing: $letter-spacing-wide;
}

.eyebrow-dot {
  width: 6px;
  height: 6px;
  background: $purple-primary;
  border-radius: $radius-full;
  animation: livePulse 2s ease-in-out infinite;
}

@keyframes livePulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.4; }
}

.hero-title {
  margin: 0 0 $space-3;
  font-family: $font-display;
  font-size: clamp(32px, 5vw, $font-size-5xl);
  font-weight: $font-weight-black;
  letter-spacing: -1px;
  line-height: $line-height-tight;
}

.title-line {
  display: block;
  color: $text-secondary;
  font-size: 0.5em;
  font-weight: $font-weight-regular;
  letter-spacing: 2px;
  text-transform: uppercase;
  margin-bottom: $space-1;
}

.title-brand {
  display: block;
  color: $text-primary;
}

.brand-accent {
  @include text-gradient($gold-bright, $gold-dark);
}

.hero-subtitle {
  margin: 0 0 $space-8;
  font-size: $font-size-md;
  color: $text-muted;
  letter-spacing: 0.5px;
}

.hero-actions {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: $space-4;
  flex-wrap: wrap;
}

.hero-btn {
  display: inline-flex;
  align-items: center;
  gap: $space-2;
  padding: $space-3 $space-6;
  border-radius: $radius-full;
  font-family: $font-body;
  font-size: $font-size-base;
  font-weight: $font-weight-semibold;
  cursor: pointer;
  transition: all $duration-normal $ease-spring;
  @include press-effect;
  @include focus-ring;
  border: none;

  .el-icon {
    width: 18px;
    height: 18px;
  }

  &--primary {
    background: linear-gradient(135deg, $purple-primary, $purple-light);
    color: $text-primary;
    box-shadow: 0 4px 16px rgba($purple-primary, 0.4), 0 0 0 1px rgba($purple-primary, 0.3);

    &:hover {
      box-shadow: 0 6px 24px rgba($purple-primary, 0.5), 0 0 0 1px rgba($purple-primary, 0.4);
      transform: translateY(-2px) scale(1.02);
    }
  }

  &--ghost {
    background: rgba($surface-card, 0.6);
    color: $text-primary;
    border: 1px solid $border-default;
    backdrop-filter: blur(10px);

    &:hover {
      background: rgba($surface-elevated, 0.8);
      border-color: rgba($purple-primary, 0.4);
      transform: translateY(-2px);
    }
  }
}

// --------------------------------------------------------------------------
// Live Strip
// --------------------------------------------------------------------------

.live-strip {
  position: relative;
  z-index: 1;
  margin-top: $space-8;
  animation: slideInUp 400ms $ease-out 200ms both;
}

.live-strip-inner {
  max-width: $content-max-width;
  margin: 0 auto;
  display: flex;
  align-items: center;
  gap: $space-4;
}

.live-badge {
  display: flex;
  align-items: center;
  gap: $space-2;
  padding: $space-1 $space-3;
  background: rgba($danger, 0.12);
  border: 1px solid rgba($danger, 0.3);
  border-radius: $radius-full;
  flex-shrink: 0;

  span:last-child {
    font-size: $font-size-xs;
    font-weight: $font-weight-bold;
    color: $danger-light;
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }
}

.live-badge-dot {
  width: 8px;
  height: 8px;
  background: $danger;
  border-radius: $radius-full;
  animation: livePulse 1.5s ease-in-out infinite;
  box-shadow: 0 0 6px rgba($danger, 0.8);
}

.live-matches-scroll {
  display: flex;
  gap: $space-3;
  overflow-x: auto;
  padding: $space-1 0;
  scrollbar-width: none;

  &::-webkit-scrollbar { display: none; }
}

.live-match-chip {
  display: flex;
  align-items: center;
  gap: $space-2;
  padding: $space-2 $space-3;
  background: $surface-card;
  border: 1px solid $border-subtle;
  border-radius: $radius-md;
  cursor: pointer;
  white-space: nowrap;
  transition: all $duration-fast $ease-out;
  @include hover-lift($shadow-md);

  .chip-home, .chip-away {
    font-size: $font-size-sm;
    color: $text-secondary;
  }

  .chip-score {
    font-family: $font-display;
    font-size: $font-size-md;
    font-weight: $font-weight-bold;
    color: $text-primary;
    padding: 0 $space-2;
  }

  .chip-minute {
    font-size: $font-size-xs;
    color: $danger-light;
    font-weight: $font-weight-semibold;
    padding: 1px $space-2;
    background: rgba($danger, 0.1);
    border-radius: $radius-full;
  }

  &:hover {
    border-color: rgba($purple-primary, 0.3);
  }
}

// --------------------------------------------------------------------------
// Stats
// --------------------------------------------------------------------------

.stats-section {
  padding: 0 $space-6;
  margin-bottom: $space-8;
}

.stats-grid {
  max-width: $content-max-width;
  margin: 0 auto;
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: $space-4;
}

.stat-card {
  @include card;
  display: flex;
  align-items: center;
  gap: $space-4;
  padding: $space-5 $space-5;
  animation: fadeIn 400ms $ease-out both;
  transition: transform $duration-normal $ease-spring, box-shadow $duration-normal $ease-out;

  &:hover {
    transform: translateY(-3px);
    box-shadow: $shadow-lg, 0 0 20px rgba($purple-primary, 0.1);
  }
}

.stat-icon-wrap {
  width: 48px;
  height: 48px;
  border-radius: $radius-md;
  background: rgba($purple-primary, 0.1);
  border: 1px solid rgba($purple-primary, 0.15);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.stat-icon {
  font-size: 22px;
  color: $purple-primary;
}

.stat-value {
  font-family: $font-display;
  font-size: $font-size-3xl;
  font-weight: $font-weight-bold;
  color: $text-primary;
  line-height: 1;
  @include text-gradient($gold-bright, $gold-dark);
}

.stat-label {
  font-size: $font-size-sm;
  color: $text-muted;
  margin-top: $space-1;
}

@media (max-width: 768px) {
  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

// --------------------------------------------------------------------------
// Section (shared via main.scss)
// --------------------------------------------------------------------------

.section {
  padding: 0 $space-6;
  max-width: $content-max-width;
  margin: 0 auto $space-8;
}

// --------------------------------------------------------------------------
// Matches Grid
// --------------------------------------------------------------------------

.matches-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: $space-4;
}

.match-card {
  @include card($radius-xl);
  padding: $space-5;
  cursor: pointer;
  animation: fadeIn 400ms $ease-out both;
  @include hover-lift($shadow-lg);
  @include focus-ring;
  position: relative;
  overflow: hidden;

  &__league {
    display: flex;
    align-items: center;
    gap: $space-2;
    margin-bottom: $space-4;
  }

  &__teams {
    display: grid;
    grid-template-columns: 1fr auto 1fr;
    align-items: center;
    gap: $space-3;
    margin-bottom: $space-4;
  }

  &__center {
    text-align: center;
    min-width: 70px;
  }

  &__time {
    margin-top: $space-1;
  }

  &__footer {
    display: flex;
    justify-content: center;
    padding-top: $space-3;
    border-top: 1px solid $border-subtle;
  }
}

.league-dot {
  width: 8px;
  height: 8px;
  border-radius: $radius-full;
  flex-shrink: 0;
}

.league-name {
  font-size: $font-size-xs;
  font-weight: $font-weight-semibold;
  color: $text-muted;
  text-transform: uppercase;
  letter-spacing: $letter-spacing-wide;
}

.match-team {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: $space-2;

  &--home { align-items: center; }
  &--away { align-items: center; }
}

.team-logo-wrap {
  width: 48px;
  height: 48px;
  border-radius: $radius-full;
  background: rgba($purple-primary, 0.08);
  border: 1.5px solid rgba($purple-primary, 0.15);
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  transition: border-color $duration-fast $ease-out;

  img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }

  .match-card:hover & {
    border-color: rgba($purple-primary, 0.35);
  }
}

.team-initial {
  font-family: $font-display;
  font-size: $font-size-xl;
  font-weight: $font-weight-bold;
  color: $purple-light;
}

.team-name {
  font-size: $font-size-sm;
  font-weight: $font-weight-medium;
  color: $text-secondary;
  text-align: center;
  max-width: 80px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.score-display {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: $space-2;

  .score-num {
    font-family: $font-display;
    font-size: $font-size-3xl;
    font-weight: $font-weight-bold;
    color: $text-primary;
    line-height: 1;
    min-width: 28px;
    text-align: center;
  }

  .score-vs {
    font-family: $font-display;
    font-size: $font-size-lg;
    color: $text-muted;
  }

  .score-sep {
    font-size: $font-size-xl;
    color: $text-muted;
    font-weight: $font-weight-bold;
  }

  &--live .score-num {
    @include text-gradient($gold-bright, $gold-dark);
  }
}

.live-minute {
  font-size: $font-size-xs;
  font-weight: $font-weight-bold;
  color: $danger-light;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.scheduled-time {
  font-size: $font-size-xs;
  color: $text-muted;
}

.status-badge {
  display: inline-flex;
  align-items: center;
  padding: $space-1 $space-3;
  border-radius: $radius-full;
  font-size: $font-size-xs;
  font-weight: $font-weight-semibold;
  letter-spacing: $letter-spacing-wide;
  text-transform: uppercase;

  &.status--live {
    background: rgba($danger, 0.12);
    color: $danger-light;
    border: 1px solid rgba($danger, 0.25);
  }

  &.status--finished {
    background: rgba($success, 0.1);
    color: $success-light;
    border: 1px solid rgba($success, 0.2);
  }

  &.status--pending {
    background: rgba($purple-light, 0.08);
    color: $text-muted;
    border: 1px solid $border-subtle;
  }
}

// --------------------------------------------------------------------------
// Players List
// --------------------------------------------------------------------------

.players-list {
  display: flex;
  flex-direction: column;
  gap: $space-2;
}

.player-card {
  @include card;
  display: flex;
  align-items: center;
  gap: $space-4;
  padding: $space-3 $space-4;
  cursor: pointer;
  animation: fadeIn 400ms $ease-out both;
  @include hover-lift($shadow-md);
  @include focus-ring;
}

.player-rank {
  width: 36px;
  height: 36px;
  border-radius: $radius-md;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  font-family: $font-display;
  font-size: $font-size-base;
  font-weight: $font-weight-bold;

  &.rank-1 {
    background: rgba($gold-bright, 0.12);
    color: $gold-bright;
    border: 1px solid rgba($gold-bright, 0.25);
    box-shadow: 0 0 12px rgba($gold-bright, 0.15);
    .rank-medal { font-size: 18px; }
  }

  &.rank-2 {
    background: rgba(192, 192, 192, 0.1);
    color: #c0c0c0;
    border: 1px solid rgba(192, 192, 192, 0.2);
    .rank-medal { font-size: 18px; }
  }

  &.rank-3 {
    background: rgba($gold-dark, 0.1);
    color: $gold-dark;
    border: 1px solid rgba($gold-dark, 0.2);
    .rank-medal { font-size: 18px; }
  }

  &.rank-4, &.rank-5 {
    background: rgba($purple-primary, 0.06);
    color: $text-muted;
    border: 1px solid $border-subtle;
  }

  &:not([class*="rank-1"]):not([class*="rank-2"]):not([class*="rank-3"]) {
    background: rgba($purple-primary, 0.06);
    color: $text-muted;
    border: 1px solid $border-subtle;
  }
}

.player-avatar-wrap {
  width: 44px;
  height: 44px;
  border-radius: $radius-full;
  background: linear-gradient(135deg, rgba($purple-primary, 0.2), rgba($purple-light, 0.1));
  border: 1.5px solid rgba($purple-primary, 0.2);
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  flex-shrink: 0;

  img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }
}

.player-initial {
  font-family: $font-display;
  font-size: $font-size-lg;
  font-weight: $font-weight-bold;
  color: $purple-light;
}

.player-info {
  flex: 1;
  min-width: 0;
}

.player-name {
  font-size: $font-size-base;
  font-weight: $font-weight-semibold;
  color: $text-primary;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.player-meta {
  display: flex;
  align-items: center;
  gap: $space-1;
  margin-top: 2px;
  font-size: $font-size-xs;
  color: $text-muted;
}

.meta-sep {
  color: $border-strong;
}

.player-position, .player-club {
  color: $text-muted;
}

.player-age {
  padding: 0 $space-2;
  background: rgba($purple-primary, 0.08);
  border-radius: $radius-full;
}

.player-score-wrap {
  text-align: center;
  flex-shrink: 0;
}

.player-score-value {
  font-family: $font-display;
  font-size: $font-size-2xl;
  font-weight: $font-weight-bold;
  @include text-gradient($gold-bright, $gold-dark);
  line-height: 1;
}

.player-score-label {
  font-size: $font-size-xs;
  color: $text-muted;
  margin-top: 2px;
}

// --------------------------------------------------------------------------
// News Grid
// --------------------------------------------------------------------------

.news-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: $space-4;
}

.news-card {
  @include card($radius-lg);
  cursor: pointer;
  animation: fadeIn 400ms $ease-out both;
  @include hover-lift($shadow-lg);
  @include focus-ring;
  overflow: hidden;
  display: flex;
  flex-direction: column;

  &__image {
    height: 160px;
    overflow: hidden;
    position: relative;

    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
      transition: transform $duration-slow $ease-out;
    }

    &--placeholder {
      background: rgba($purple-primary, 0.08);
      display: flex;
      align-items: center;
      justify-content: center;
      color: $purple-light;
      font-size: 32px;
    }
  }

  &__overlay {
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    height: 60px;
    background: linear-gradient(transparent, rgba($surface-card, 0.8));
  }

  &:hover &__image img {
    transform: scale(1.05);
  }

  &__content {
    padding: $space-4;
    flex: 1;
  }

  &__meta {
    display: flex;
    align-items: center;
    gap: $space-3;
    margin-bottom: $space-2;
  }
}

.news-source {
  padding: 1px $space-2;
  background: rgba($purple-primary, 0.12);
  border: 1px solid rgba($purple-primary, 0.2);
  border-radius: $radius-full;
  font-size: $font-size-xs;
  font-weight: $font-weight-semibold;
  color: $purple-light;
}

.news-views {
  font-size: $font-size-xs;
  color: $text-muted;
}

.news-title {
  margin: 0;
  font-size: $font-size-base;
  font-weight: $font-weight-semibold;
  color: $text-primary;
  line-height: $line-height-normal;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  transition: color $duration-fast $ease-out;

  .news-card:hover & {
    color: $purple-light;
  }
}

// --------------------------------------------------------------------------
// Leagues Grid
// --------------------------------------------------------------------------

.leagues-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: $space-3;
}

.league-card {
  @include card($radius-xl);
  padding: $space-5 $space-4;
  cursor: pointer;
  animation: fadeIn 400ms $ease-out both;
  @include hover-lift($shadow-lg);
  @include focus-ring;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  gap: $space-3;
  position: relative;
  overflow: hidden;

  &__bg {
    position: absolute;
    inset: 0;
    background: linear-gradient(
      135deg,
      rgba($purple-primary, 0.06) 0%,
      rgba($gold-dark, 0.03) 100%
    );
    opacity: 0;
    transition: opacity $duration-normal $ease-out;
  }

  &:hover &__bg { opacity: 1; }

  &__icon {
    width: 40px;
    height: 40px;
    display: flex;
    align-items: center;
    justify-content: center;
    position: relative;
    z-index: 1;
    filter: drop-shadow(0 0 8px rgba($purple-primary, 0.3));
  }

  &__info {
    position: relative;
    z-index: 1;
  }

  &__name {
    font-family: $font-display;
    font-size: $font-size-base;
    font-weight: $font-weight-bold;
    color: $text-primary;
    letter-spacing: $letter-spacing-tight;
  }

  &__teams {
    font-size: $font-size-xs;
    color: $text-muted;
    margin-top: 2px;
  }

  &__action {
    position: absolute;
    top: $space-3;
    right: $space-3;
    width: 24px;
    height: 24px;
    border-radius: $radius-full;
    background: rgba($purple-primary, 0.08);
    display: flex;
    align-items: center;
    justify-content: center;
    opacity: 0;
    transform: translateX(-4px);
    transition: all $duration-normal $ease-spring;

    .el-icon {
      width: 14px;
      height: 14px;
      color: $purple-light;
    }
  }

  &:hover &__action {
    opacity: 1;
    transform: translateX(0);
  }
}

@media (max-width: 900px) {
  .leagues-grid { grid-template-columns: repeat(3, 1fr); }
}

@media (max-width: 600px) {
  .leagues-grid { grid-template-columns: repeat(2, 1fr); }
}

// --------------------------------------------------------------------------
// Empty State
// --------------------------------------------------------------------------

.empty-state {
  text-align: center;
  padding: $space-10 $space-4;
  color: $text-muted;
  background: $surface-card;
  border: 1px solid $border-subtle;
  border-radius: $radius-xl;
}

.empty-icon {
  font-size: 40px;
  margin-bottom: $space-3;
  opacity: 0.4;
}

// --------------------------------------------------------------------------
// Section Header (override from main.scss)
// --------------------------------------------------------------------------

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: $space-5;

  h2 {
    margin: 0;
    font-family: $font-display;
    font-size: $font-size-xl;
    font-weight: $font-weight-bold;
    color: $text-primary;
    display: flex;
    align-items: center;
    gap: $space-2;
    letter-spacing: $letter-spacing-tight;
  }

  .view-all {
    display: inline-flex;
    align-items: center;
    gap: $space-1;
    font-size: $font-size-sm;
    color: $purple-light;
    transition: all $duration-fast $ease-out;

    &:hover {
      color: $gold-bright;
      gap: $space-2;
    }
  }
}

.section-icon {
  font-size: 20px;

  &--gold { color: $gold-bright; }
}

.arrow-icon {
  width: 14px;
  height: 14px;
  transition: transform $duration-fast $ease-out;
}

// --------------------------------------------------------------------------
// Animations
// --------------------------------------------------------------------------

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(12px); }
  to   { opacity: 1; transform: translateY(0); }
}

@keyframes slideInUp {
  from { opacity: 0; transform: translateY(20px); }
  to   { opacity: 1; transform: translateY(0); }
}

@media (prefers-reduced-motion: reduce) {
  .hero-eyebrow .eyebrow-dot,
  .live-badge-dot {
    animation: none;
  }

  .stat-card,
  .match-card,
  .player-card,
  .news-card,
  .league-card {
    animation: none;
  }
}
</style>
