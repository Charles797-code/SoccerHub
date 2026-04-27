<template>
  <div class="page-container">
    <!-- Page Header -->
    <div class="page-header-custom">
      <div class="header-left">
        <h1 class="page-title">
          <el-icon class="title-icon"><DataLine /></el-icon>
          联赛数据
        </h1>
        <p class="page-subtitle">积分榜 · 射手榜 · 助攻榜 · 纪律榜</p>
      </div>
      <div class="header-actions">
        <el-select
          v-model="selectedLeague"
          placeholder="选择联赛"
          size="large"
          class="league-select"
          :disabled="loadingLeague"
        >
          <template #prefix>
            <el-icon><Trophy /></el-icon>
          </template>
          <el-option
            v-for="league in leagues"
            :key="league"
            :label="getLeagueNameCN(league)"
            :value="league"
          />
        </el-select>
      </div>
    </div>

    <!-- Tabs -->
    <div class="standings-tabs">
      <el-tabs v-model="activeTab" @tab-change="handleTabChange">
        <el-tab-pane name="standings">
          <template #label>
            <div class="tab-label">
              <el-icon><Trophy /></el-icon>
              <span>积分榜</span>
            </div>
          </template>
        </el-tab-pane>
        <el-tab-pane name="scorers">
          <template #label>
            <div class="tab-label">
              <el-icon><Aim /></el-icon>
              <span>射手榜</span>
            </div>
          </template>
        </el-tab-pane>
        <el-tab-pane name="assists">
          <template #label>
            <div class="tab-label">
              <el-icon><Promotion /></el-icon>
              <span>助攻榜</span>
            </div>
          </template>
        </el-tab-pane>
        <el-tab-pane name="yellowCards">
          <template #label>
            <div class="tab-label">
              <el-icon><Warning /></el-icon>
              <span>黄牌榜</span>
            </div>
          </template>
        </el-tab-pane>
        <el-tab-pane name="redCards">
          <template #label>
            <div class="tab-label">
              <el-icon><CircleClose /></el-icon>
              <span>红牌榜</span>
            </div>
          </template>
        </el-tab-pane>
      </el-tabs>

      <!-- Tab Content -->
      <div class="tab-content">
        <!-- Standings Table -->
        <div v-if="activeTab === 'standings'" class="table-wrapper">
          <el-table :data="standings" :row-class-name="getRowClassName" class="premium-table">
            <el-table-column prop="position" label="排名" width="70" align="center">
              <template #default="{ row }">
                <div class="rank-cell" :class="getRankClass(row.position)">
                  <span v-if="row.position <= 3" class="rank-medal-icon">
                    <el-icon><Medal /></el-icon>
                  </span>
                  <span v-else class="rank-num">{{ row.position }}</span>
                </div>
              </template>
            </el-table-column>
            <el-table-column label="俱乐部" min-width="180">
              <template #default="{ row }">
                <div class="club-cell">
                  <div class="club-logo-wrap">
                    <img
                      v-if="getClubLogo(row.clubId)"
                      :src="getImageUrl(getClubLogo(row.clubId))"
                      :alt="getClubName(row.clubId)"
                    />
                    <span v-else class="club-initial">{{ getClubName(row.clubId)?.charAt(0) }}</span>
                  </div>
                  <span class="club-name">{{ getClubName(row.clubId) }}</span>
                </div>
              </template>
            </el-table-column>
            <el-table-column prop="played" label="场次" width="70" align="center" />
            <el-table-column prop="won" label="胜" width="60" align="center">
              <template #default="{ row }">
                <span class="result-cell result-cell--win">{{ row.won }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="drawn" label="平" width="60" align="center">
              <template #default="{ row }">
                <span class="result-cell result-cell--draw">{{ row.drawn }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="lost" label="负" width="60" align="center">
              <template #default="{ row }">
                <span class="result-cell result-cell--lose">{{ row.lost }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="goalsFor" label="进球" width="70" align="center" />
            <el-table-column prop="goalsAgainst" label="失球" width="70" align="center" />
            <el-table-column prop="goalDiff" label="净胜球" width="80" align="center">
              <template #default="{ row }">
                <span class="diff-cell" :class="row.goalDiff > 0 ? 'diff--pos' : row.goalDiff < 0 ? 'diff--neg' : ''">
                  {{ row.goalDiff > 0 ? '+' : '' }}{{ row.goalDiff }}
                </span>
              </template>
            </el-table-column>
            <el-table-column prop="points" label="积分" width="80" align="center">
              <template #default="{ row }">
                <div class="points-cell">
                  <span class="points-value">{{ row.points }}</span>
                </div>
              </template>
            </el-table-column>
          </el-table>
        </div>

        <!-- Scorers / Assists / Cards Table -->
        <div v-else class="table-wrapper">
          <el-table :data="currentTableData" class="premium-table">
            <el-table-column label="排名" width="70" align="center">
              <template #default="{ row }">
                <div class="rank-cell" :class="getRankClass(row.rank)">
                  <span v-if="row.rank <= 3" class="rank-medal-icon">
                    <el-icon><Medal /></el-icon>
                  </span>
                  <span v-else class="rank-num">{{ row.rank }}</span>
                </div>
              </template>
            </el-table-column>
            <el-table-column label="球员" min-width="180">
              <template #default="{ row }">
                <div class="player-cell">
                  <div class="player-avatar-wrap">
                    <img v-if="row.avatarUrl" :src="getImageUrl(row.avatarUrl)" :alt="row.playerNameCn || row.playerName" />
                    <span v-else class="player-initial">{{ (row.playerNameCn || row.playerName)?.charAt(0) }}</span>
                  </div>
                  <div class="player-name-wrap">
                    <span class="player-name">{{ row.playerNameCn || row.playerName }}</span>
                    <span v-if="row.clubShort" class="club-tag-sm">{{ row.clubShort }}</span>
                  </div>
                </div>
              </template>
            </el-table-column>
            <el-table-column label="位置" width="80" align="center">
              <template #default="{ row }">
                <span class="position-badge" :class="`pos--${row.position?.toLowerCase()}`">
                  {{ positionMap[row.position] || row.position }}
                </span>
              </template>
            </el-table-column>
            <el-table-column prop="appearances" label="出场" width="70" align="center" />
            <el-table-column :label="activeTab === 'scorers' ? '进球' : activeTab === 'assists' ? '助攻' : activeTab === 'yellowCards' ? '黄牌' : '红牌'"
              :width="activeTab === 'yellowCards' || activeTab === 'redCards' ? '80' : '90'" align="center">
              <template #default="{ row }">
                <span class="stat-highlight" :class="getStatClass(activeTab)">
                  {{ activeTab === 'scorers' ? row.goals : activeTab === 'assists' ? row.assists : activeTab === 'yellowCards' ? row.yellowCards : row.redCards }}
                </span>
              </template>
            </el-table-column>
            <el-table-column v-if="activeTab !== 'yellowCards' && activeTab !== 'redCards'" prop="goals" label="进球" width="70" align="center" />
            <el-table-column v-if="activeTab !== 'yellowCards' && activeTab !== 'redCards'" prop="assists" label="助攻" width="70" align="center" />
          </el-table>
        </div>

        <!-- Empty State -->
        <div v-if="currentTableData.length === 0 && !tableLoading" class="empty-state">
          <div class="empty-visual">
            <svg width="64" height="64" viewBox="0 0 64 64" fill="none">
              <circle cx="32" cy="32" r="28" stroke="#7c3aed" stroke-width="2" stroke-dasharray="5 3" opacity="0.3"/>
              <rect x="16" y="22" width="32" height="4" rx="2" fill="#7c3aed" opacity="0.2"/>
              <rect x="16" y="30" width="24" height="4" rx="2" fill="#7c3aed" opacity="0.15"/>
              <rect x="16" y="38" width="28" height="4" rx="2" fill="#7c3aed" opacity="0.1"/>
            </svg>
          </div>
          <p>暂无数据</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import {
  DataLine, Trophy, Aim, Promotion, Warning,
  CircleClose, Medal
} from '@element-plus/icons-vue'
import { clubApi, standingsApi } from '@/api'

const activeTab = ref('standings')
const standings = ref<any[]>([])
const scorers = ref<any[]>([])
const assists = ref<any[]>([])
const yellowCards = ref<any[]>([])
const redCards = ref<any[]>([])
const leagues = ref<string[]>([])
const selectedLeague = ref('')
const loadingLeague = ref(true)
const tableLoading = ref(false)

const clubNameMap = ref<Record<number, string>>({})
const clubLogoMap = ref<Record<number, string>>({})

const positionMap: Record<string, string> = {
  GK: '门将', DF: '后卫', MF: '中场', FW: '前锋'
}

const currentTableData = computed(() => {
  switch (activeTab.value) {
    case 'scorers': return scorers.value
    case 'assists': return assists.value
    case 'yellowCards': return yellowCards.value
    case 'redCards': return redCards.value
    default: return []
  }
})

function getClubName(clubId: number) {
  return clubNameMap.value[clubId] || `球队${clubId}`
}

function getClubLogo(clubId: number) {
  return clubLogoMap.value[clubId] || ''
}

function getImageUrl(path: string) {
  if (!path) return ''
  if (path.startsWith('http://') || path.startsWith('https://')) return path
  if (path.startsWith('/uploads/')) return 'http://localhost:8080' + path
  return 'http://localhost:8080/api' + path
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

function getRankClass(rank: number) {
  if (rank === 1) return 'rank--gold'
  if (rank === 2) return 'rank--silver'
  if (rank === 3) return 'rank--bronze'
  return ''
}

function getRowClassName({ row }: any) {
  if (row.position <= 4) return 'top-tier'
  return ''
}

function getStatClass(tab: string) {
  if (tab === 'scorers' || tab === 'assists') return 'stat--goals'
  if (tab === 'yellowCards') return 'stat--yellow'
  if (tab === 'redCards') return 'stat--red'
  return ''
}

watch(selectedLeague, () => {
  if (selectedLeague.value) {
    fetchAllData()
  }
})

onMounted(async () => {
  try {
    const leaguesRes = await clubApi.getLeagues()
    leagues.value = leaguesRes.data.data || []
    loadingLeague.value = false

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
    loadingLeague.value = false
  }
})

async function fetchAllData() {
  if (!selectedLeague.value) return
  tableLoading.value = true
  try {
    await Promise.all([
      fetchStandings(),
      fetchScorers(),
      fetchAssists(),
      fetchYellowCards(),
      fetchRedCards(),
    ])
  } finally {
    tableLoading.value = false
  }
}

function handleTabChange() {
  // Data is loaded eagerly in fetchAllData
}

async function fetchStandings() {
  if (!selectedLeague.value) return
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
    yellowCards.value = res.data.data?.records || []
  } catch (e) { console.error(e) }
}

async function fetchRedCards() {
  try {
    const res = await standingsApi.getRedCards({ league: selectedLeague.value, page: 1, pageSize: 50 })
    redCards.value = res.data.data?.records || []
  } catch (e) { console.error(e) }
}
</script>

<style scoped lang="scss">
@use '@/styles/tokens' as *;

.page-container {
  background: $surface-dark;
  padding: $space-6 $space-6 $space-8;
  max-width: $content-max-width;
  margin: 0 auto;
}

.page-header-custom {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: $space-6;
  margin-bottom: $space-5;
  flex-wrap: wrap;
}

.header-left {
  .page-title {
    margin: 0 0 $space-1;
    font-family: $font-display;
    font-size: $font-size-2xl;
    font-weight: $font-weight-bold;
    color: $text-primary;
    letter-spacing: $letter-spacing-tight;
    display: flex;
    align-items: center;
    gap: $space-2;
  }

  .title-icon {
    font-size: 24px;
    color: $gold-bright;
    filter: drop-shadow(0 0 8px rgba($gold-bright, 0.4));
  }

  .page-subtitle {
    margin: 0;
    font-size: $font-size-sm;
    color: $text-muted;
  }
}

.league-select {
  width: 260px;

  :deep(.el-input__wrapper) {
    background: $surface-card !important;
    border-radius: $radius-md !important;
  }
}

// Tabs
.standings-tabs {
  @include card($radius-xl);
  overflow: hidden;
  animation: fadeIn 400ms $ease-out;

  :deep(.el-tabs__header) {
    background: $surface-mid;
    margin: 0;
    padding: 0 $space-4;
  }

  :deep(.el-tabs__nav-wrap::after) {
    display: none;
  }

  :deep(.el-tabs__item) {
    height: 52px;
    line-height: 52px;
    padding: 0 $space-5;
    color: $text-muted;
    font-family: $font-body;
    font-size: $font-size-base;
    font-weight: $font-weight-medium;

    &:hover { color: $text-primary; }
    &.is-active { color: $text-primary; font-weight: $font-weight-semibold; }
  }

  :deep(.el-tabs__active-bar) {
    background: linear-gradient(90deg, $purple-primary, $gold-bright);
    height: 3px;
    border-radius: $radius-full;
  }

  :deep(.el-tabs__content) { padding: 0; }
}

.tab-label {
  display: flex;
  align-items: center;
  gap: $space-2;

  .el-icon {
    width: 16px;
    height: 16px;
  }
}

// Table Wrapper
.table-wrapper {
  animation: fadeIn 300ms $ease-out;
}

// Premium Table
.premium-table {
  border-radius: $radius-lg;
  overflow: hidden;
  background: $surface-card !important;

  :deep(.el-table__header-wrapper th) {
    background: $surface-mid !important;
    border-bottom: 1px solid $border-default !important;
  }

  :deep(.el-table__body-wrapper),
  :deep(.el-table__body),
  :deep(.el-table__row),
  :deep(.el-table__empty-block) {
    background: transparent !important;
  }

  :deep(.el-table__row td) {
    background: transparent !important;
  }

  :deep(.el-table__body-wrapper tr) {
    &.top-tier td {
      background: rgba($purple-primary, 0.03) !important;
    }

    &:hover td {
      background: rgba($purple-primary, 0.06) !important;
    }
  }

  :deep(.el-table__cell) {
    background: transparent !important;
    padding: $space-3 0;
    border-bottom: 1px solid $border-subtle !important;
  }
}

// Tab content needs card background too
.tab-content {
  background: $surface-card;
  padding: $space-5;
  border-radius: 0 0 $radius-xl $radius-xl;
}

// Rank Cell
.rank-cell {
  display: flex;
  align-items: center;
  justify-content: center;

  &.rank--gold {
    .rank-medal-icon {
      font-size: 20px;
      color: $gold-bright;
      filter: drop-shadow(0 0 6px rgba($gold-bright, 0.6));
    }
  }

  &.rank--silver {
    .rank-medal-icon {
      font-size: 20px;
      color: #c0c0c0;
      filter: drop-shadow(0 0 4px rgba(192, 192, 192, 0.4));
    }
  }

  &.rank--bronze {
    .rank-medal-icon {
      font-size: 20px;
      color: $gold-dark;
      filter: drop-shadow(0 0 4px rgba($gold-dark, 0.4));
    }
  }

  .rank-num {
    font-family: $font-display;
    font-size: $font-size-base;
    font-weight: $font-weight-bold;
    color: $text-muted;
  }
}

// Club Cell
.club-cell {
  display: flex;
  align-items: center;
  gap: $space-3;
}

.club-logo-wrap {
  width: 32px;
  height: 32px;
  border-radius: $radius-full;
  background: rgba($purple-primary, 0.08);
  border: 1px solid rgba($purple-primary, 0.15);
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

.club-initial {
  font-family: $font-display;
  font-size: $font-size-sm;
  font-weight: $font-weight-bold;
  color: $purple-light;
}

.club-name {
  font-size: $font-size-base;
  font-weight: $font-weight-medium;
  color: $text-primary;
}

// Result Cells
.result-cell {
  font-weight: $font-weight-semibold;
  font-size: $font-size-base;

  &--win { color: $success-light; }
  &--draw { color: $text-muted; }
  &--lose { color: $danger-light; }
}

// Diff Cell
.diff-cell {
  font-weight: $font-weight-semibold;
  font-size: $font-size-base;

  &.diff--pos { color: $success-light; }
  &.diff--neg { color: $danger-light; }
}

// Points Cell
.points-cell {
  display: flex;
  align-items: center;
  justify-content: center;
}

.points-value {
  font-family: $font-display;
  font-size: $font-size-xl;
  font-weight: $font-weight-bold;
  @include text-gradient($gold-bright, $gold-dark);
  line-height: 1;
}

// Player Cell
.player-cell {
  display: flex;
  align-items: center;
  gap: $space-3;
}

.player-avatar-wrap {
  width: 36px;
  height: 36px;
  border-radius: $radius-full;
  background: linear-gradient(135deg, rgba($purple-primary, 0.15), rgba($purple-light, 0.1));
  border: 1px solid rgba($purple-primary, 0.2);
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
  font-size: $font-size-sm;
  font-weight: $font-weight-bold;
  color: $purple-light;
}

.player-name-wrap {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.player-name {
  font-size: $font-size-base;
  font-weight: $font-weight-medium;
  color: $text-primary;
}

.club-tag-sm {
  font-size: $font-size-xs;
  color: $text-muted;
  background: rgba($purple-light, 0.08);
  padding: 0 $space-2;
  border-radius: $radius-full;
  border: 1px solid $border-subtle;
  width: fit-content;
}

// Position Badge
.position-badge {
  display: inline-flex;
  align-items: center;
  padding: 2px $space-2;
  border-radius: $radius-sm;
  font-size: $font-size-xs;
  font-weight: $font-weight-semibold;
  letter-spacing: 0.3px;

  &.pos--gk { background: rgba($info, 0.12); color: $info; border: 1px solid rgba($info, 0.2); }
  &.pos--df { background: rgba($success, 0.12); color: $success; border: 1px solid rgba($success, 0.2); }
  &.pos--mf { background: rgba($purple-light, 0.12); color: $purple-light; border: 1px solid rgba($purple-light, 0.2); }
  &.pos--fw { background: rgba($warning, 0.12); color: $warning; border: 1px solid rgba($warning, 0.2); }
}

// Stat Highlight
.stat-highlight {
  font-family: $font-display;
  font-size: $font-size-xl;
  font-weight: $font-weight-bold;
  line-height: 1;

  &.stat--goals { @include text-gradient($gold-bright, $gold-dark); }
  &.stat--yellow { color: $warning; }
  &.stat--red { color: $danger-light; }
}

// Empty State
.empty-state {
  text-align: center;
  padding: $space-10 $space-4;
  color: $text-muted;
  font-size: $font-size-sm;

  .empty-visual {
    margin-bottom: $space-4;
    opacity: 0.5;
  }
}

// Animation
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(8px); }
  to   { opacity: 1; transform: translateY(0); }
}
</style>
