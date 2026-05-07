<template>
  <div class="mobile-standings">
    <!-- Header -->
    <div class="page-header">
      <div class="header-left">
        <h1>积分榜</h1>
        <p class="page-subtitle">{{ getLeagueShort(selectedLeague) }}</p>
      </div>
    </div>

    <!-- League Filter -->
    <div class="filter-tabs">
      <div
        v-for="league in leagues"
        :key="league"
        class="tab"
        :class="{ active: selectedLeague === league }"
        @click="selectLeague(league)"
      >
        {{ getLeagueShort(league) }}
      </div>
    </div>

    <!-- Tabs -->
    <div class="tabs">
      <div
        v-for="tab in tabs"
        :key="tab.key"
        class="tab-btn"
        :class="{ active: activeTab === tab.key }"
        @click="activeTab = tab.key"
      >
        {{ tab.label }}
      </div>
    </div>

    <!-- Standings Table -->
    <div class="standings-table" v-if="activeTab === 'standings'">
      <div class="table-header">
        <span class="col-rank">排名</span>
        <span class="col-team">球队</span>
        <span class="col-stat">胜</span>
        <span class="col-stat">平</span>
        <span class="col-stat">负</span>
        <span class="col-stat">积分</span>
      </div>
      <div
        v-for="item in standings"
        :key="item.position"
        class="table-row"
        :class="{ 'top-tier': item.position <= 4 }"
        @click="router.push(`/m/clubs/${item.clubId}`)"
      >
        <span class="col-rank">
          <span v-if="item.position <= 3" class="rank-medal" :class="`rank-${item.position}`">
            <el-icon><Medal /></el-icon>
          </span>
          <span v-else>{{ item.position }}</span>
        </span>
        <span class="col-team">
          <img v-if="getClubLogo(item.clubId)" :src="getImageUrl(getClubLogo(item.clubId))" :alt="getClubName(item.clubId)" class="team-logo" />
          <div v-else class="team-logo team-logo--placeholder">{{ getClubName(item.clubId)?.charAt(0) }}</div>
          <span class="team-name">{{ getClubName(item.clubId) }}</span>
        </span>
        <span class="col-stat result-win">{{ item.won }}</span>
        <span class="col-stat">{{ item.drawn }}</span>
        <span class="col-stat result-lose">{{ item.lost }}</span>
        <span class="col-stat points">{{ item.points }}</span>
      </div>
      <div v-if="standings.length === 0 && !loading" class="empty">
        <Trophy class="empty-icon" />
        <p>暂无积分数据</p>
      </div>
    </div>

    <!-- Scorers Table -->
    <div class="standings-table" v-else-if="activeTab === 'scorers'">
      <div class="table-header">
        <span class="col-rank">排名</span>
        <span class="col-player">球员</span>
        <span class="col-stat">进球</span>
      </div>
      <div
        v-for="(item, index) in scorers"
        :key="item.playerId || index"
        class="table-row"
        @click="router.push(`/m/players/${item.playerId}`)"
      >
        <span class="col-rank">
          <span v-if="index < 3" class="rank-medal" :class="`rank-${index + 1}`">
            <el-icon><Medal /></el-icon>
          </span>
          <span v-else>{{ index + 1 }}</span>
        </span>
        <span class="col-player">
          <img v-if="item.avatarUrl" :src="getImageUrl(item.avatarUrl)" :alt="item.playerName" class="player-avatar" />
          <div v-else class="player-avatar player-avatar--placeholder">{{ (item.playerNameCn || item.playerName)?.charAt(0) }}</div>
          <div class="player-info">
            <span class="player-name">{{ item.playerNameCn || item.playerName }}</span>
            <span class="player-club">{{ item.clubShort }}</span>
          </div>
        </span>
        <span class="col-stat goals">{{ item.goals }}</span>
      </div>
      <div v-if="scorers.length === 0 && !loading" class="empty">
        <Aim class="empty-icon" />
        <p>暂无射手数据</p>
      </div>
    </div>

    <!-- Assists Table -->
    <div class="standings-table" v-else-if="activeTab === 'assists'">
      <div class="table-header">
        <span class="col-rank">排名</span>
        <span class="col-player">球员</span>
        <span class="col-stat">助攻</span>
      </div>
      <div
        v-for="(item, index) in assists"
        :key="item.playerId || index"
        class="table-row"
        @click="router.push(`/m/players/${item.playerId}`)"
      >
        <span class="col-rank">
          <span v-if="index < 3" class="rank-medal" :class="`rank-${index + 1}`">
            <el-icon><Medal /></el-icon>
          </span>
          <span v-else>{{ index + 1 }}</span>
        </span>
        <span class="col-player">
          <img v-if="item.avatarUrl" :src="getImageUrl(item.avatarUrl)" :alt="item.playerName" class="player-avatar" />
          <div v-else class="player-avatar player-avatar--placeholder">{{ (item.playerNameCn || item.playerName)?.charAt(0) }}</div>
          <div class="player-info">
            <span class="player-name">{{ item.playerNameCn || item.playerName }}</span>
            <span class="player-club">{{ item.clubShort }}</span>
          </div>
        </span>
        <span class="col-stat assists">{{ item.assists }}</span>
      </div>
      <div v-if="assists.length === 0 && !loading" class="empty">
        <Promotion class="empty-icon" />
        <p>暂无助攻数据</p>
      </div>
    </div>

    <!-- Cards Table -->
    <div class="standings-table" v-else>
      <div class="table-header">
        <span class="col-rank">排名</span>
        <span class="col-player">球员</span>
        <span class="col-stat">{{ activeTab === 'yellowCards' ? '黄牌' : '红牌' }}</span>
      </div>
      <div
        v-for="(item, index) in cards"
        :key="item.playerId || index"
        class="table-row"
        @click="router.push(`/m/players/${item.playerId}`)"
      >
        <span class="col-rank">{{ index + 1 }}</span>
        <span class="col-player">
          <img v-if="item.avatarUrl" :src="getImageUrl(item.avatarUrl)" :alt="item.playerName" class="player-avatar" />
          <div v-else class="player-avatar player-avatar--placeholder">{{ (item.playerNameCn || item.playerName)?.charAt(0) }}</div>
          <div class="player-info">
            <span class="player-name">{{ item.playerNameCn || item.playerName }}</span>
            <span class="player-club">{{ item.clubShort }}</span>
          </div>
        </span>
        <span class="col-stat" :class="activeTab === 'yellowCards' ? 'yellow-card' : 'red-card'">
          {{ activeTab === 'yellowCards' ? item.yellowCards : item.redCards }}
        </span>
      </div>
      <div v-if="cards.length === 0 && !loading" class="empty">
        <Warning class="empty-icon" />
        <p>暂无数据</p>
      </div>
    </div>

    <div v-if="loading" class="loading">
      <el-icon class="is-loading"><Loading /></el-icon>
      加载中...
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Medal, Trophy, Aim, Promotion, Warning, Loading } from '@element-plus/icons-vue'
import { clubApi, standingsApi } from '@/api'

const router = useRouter()

const leagues = ref<string[]>([])
const selectedLeague = ref('')
const activeTab = ref('standings')
const loading = ref(false)

const standings = ref<any[]>([])
const scorers = ref<any[]>([])
const assists = ref<any[]>([])
const cards = ref<any[]>([])

const clubNameMap = ref<Record<number, string>>({})
const clubLogoMap = ref<Record<number, string>>({})

const tabs = [
  { key: 'standings', label: '积分榜' },
  { key: 'scorers', label: '射手榜' },
  { key: 'assists', label: '助攻榜' },
  { key: 'yellowCards', label: '黄牌' },
  { key: 'redCards', label: '红牌' }
]

const leagueNameMap: Record<string, string> = {
  'La Liga': '西甲',
  'Premier League': '英超',
  'Bundesliga': '德甲',
  'Serie A': '意甲',
  'Ligue 1': '法甲'
}

function getLeagueShort(league: string) {
  return leagueNameMap[league] || league || '选择联赛'
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

function selectLeague(league: string) {
  selectedLeague.value = league
}

async function fetchData() {
  if (!selectedLeague.value) return
  loading.value = true
  try {
    await Promise.all([
      fetchStandings(),
      fetchScorers(),
      fetchAssists(),
      activeTab.value === 'yellowCards' ? fetchYellowCards() : activeTab.value === 'redCards' ? fetchRedCards() : Promise.resolve()
    ])
  } finally {
    loading.value = false
  }
}

async function fetchStandings() {
  try {
    const res = await standingsApi.get({ league: selectedLeague.value })
    standings.value = res.data.data?.records || []
  } catch (e) { console.error(e) }
}

async function fetchScorers() {
  try {
    const res = await standingsApi.getScorers({ league: selectedLeague.value, page: 1, pageSize: 50 })
    scorers.value = res.data.data?.records || []
  } catch (e) { console.error(e) }
}

async function fetchAssists() {
  try {
    const res = await standingsApi.getAssists({ league: selectedLeague.value, page: 1, pageSize: 50 })
    assists.value = res.data.data?.records || []
  } catch (e) { console.error(e) }
}

async function fetchYellowCards() {
  try {
    const res = await standingsApi.getYellowCards({ league: selectedLeague.value, page: 1, pageSize: 50 })
    cards.value = res.data.data?.records || []
  } catch (e) { console.error(e) }
}

async function fetchRedCards() {
  try {
    const res = await standingsApi.getRedCards({ league: selectedLeague.value, page: 1, pageSize: 50 })
    cards.value = res.data.data?.records || []
  } catch (e) { console.error(e) }
}

watch(activeTab, (val) => {
  if (val === 'yellowCards' && cards.value.length === 0) fetchYellowCards()
  if (val === 'redCards' && cards.value.length === 0) fetchRedCards()
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

    if (leagues.value.length > 0) {
      selectedLeague.value = leagues.value[0]
    }
  } catch (e) {
    console.error(e)
  }
})

watch(selectedLeague, () => {
  fetchData()
})
</script>

<style scoped lang="scss">
@use '@/styles/tokens' as *;

.mobile-standings {
  padding: 16px;
  padding-bottom: 80px;
  position: relative;

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

.page-header {
  margin-bottom: 16px;

  h1 {
    margin: 0;
    font-size: 22px;
    font-weight: 700;
    color: #fff;
  }

  .page-subtitle {
    margin: 4px 0 0;
    font-size: 13px;
    color: $text-muted;
  }
}

.filter-tabs {
  display: flex;
  gap: 8px;
  overflow-x: auto;
  margin-bottom: 12px;
  padding-bottom: 4px;
  -webkit-overflow-scrolling: touch;

  &::-webkit-scrollbar { display: none; }
}

.tab {
  padding: 8px 16px;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 20px;
  font-size: 13px;
  color: rgba(255, 255, 255, 0.6);
  white-space: nowrap;
  cursor: pointer;
  transition: all 0.2s;
  flex-shrink: 0;

  &.active {
    background: $purple-primary;
    color: #fff;
  }
}

.tabs {
  display: flex;
  gap: 4px;
  background: rgba(255, 255, 255, 0.03);
  border-radius: 10px;
  padding: 4px;
  margin-bottom: 16px;
}

.tab-btn {
  flex: 1;
  padding: 10px 8px;
  text-align: center;
  font-size: 13px;
  color: rgba(255, 255, 255, 0.6);
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s;

  &.active {
    background: $purple-primary;
    color: #fff;
    font-weight: 600;
  }
}

.standings-table {
  background: rgba(255, 255, 255, 0.03);
  border-radius: 12px;
  overflow: hidden;
}

.table-header {
  display: flex;
  align-items: center;
  padding: 12px;
  background: rgba(255, 255, 255, 0.05);
  font-size: 12px;
  color: $text-muted;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.table-row {
  display: flex;
  align-items: center;
  padding: 12px;
  border-top: 1px solid rgba(255, 255, 255, 0.05);
  cursor: pointer;
  transition: background 0.2s;

  &:active {
    background: rgba(255, 255, 255, 0.05);
  }

  &.top-tier {
    background: rgba($purple-primary, 0.05);
  }
}

.col-rank {
  width: 40px;
  text-align: center;
  font-weight: 600;
  color: $text-muted;
}

.col-team {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 10px;
  min-width: 0;
}

.col-player {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 10px;
  min-width: 0;
}

.col-stat {
  width: 36px;
  text-align: center;
  font-size: 14px;
  color: $text-secondary;
}

.rank-medal {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
  border-radius: 6px;

  .el-icon {
    font-size: 16px;
  }

  &.rank-1 {
    background: rgba($gold-bright, 0.2);
    color: $gold-bright;
  }
  &.rank-2 {
    background: rgba(192, 192, 192, 0.2);
    color: #c0c0c0;
  }
  &.rank-3 {
    background: rgba($gold-dark, 0.2);
    color: $gold-dark;
  }
}

.team-logo {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  object-fit: cover;
  flex-shrink: 0;

  &--placeholder {
    background: rgba($purple-primary, 0.2);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 14px;
    font-weight: 700;
    color: $purple-light;
  }
}

.team-name {
  font-size: 13px;
  font-weight: 500;
  color: #fff;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.player-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  object-fit: cover;
  flex-shrink: 0;

  &--placeholder {
    background: rgba($purple-primary, 0.2);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 14px;
    font-weight: 700;
    color: $purple-light;
  }
}

.player-info {
  flex: 1;
  min-width: 0;
}

.player-name {
  display: block;
  font-size: 13px;
  font-weight: 500;
  color: #fff;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.player-club {
  font-size: 11px;
  color: $text-muted;
}

.points {
  font-family: $font-display;
  font-size: 16px;
  font-weight: 700;
  @include text-gradient($gold-bright, $gold-dark);
}

.goals, .assists {
  font-family: $font-display;
  font-size: 16px;
  font-weight: 700;
  @include text-gradient($gold-bright, $gold-dark);
}

.result-win { color: $success-light; }
.result-lose { color: $danger-light; }

.yellow-card { color: $warning; }
.red-card { color: $danger-light; }

.empty {
  text-align: center;
  padding: 48px 16px;
  color: $text-muted;

  .empty-icon {
    font-size: 40px;
    margin-bottom: 12px;
    opacity: 0.5;
  }
}

.loading {
  text-align: center;
  padding: 32px;
  color: $text-muted;

  .el-icon {
    font-size: 24px;
    margin-bottom: 8px;
    display: block;
  }
}
</style>
