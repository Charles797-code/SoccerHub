<template>
  <div class="page-container">
    <!-- Page Header -->
    <div class="page-header-custom">
      <div class="header-left">
        <h1 class="page-title">
          <el-icon class="title-icon"><Timer /></el-icon>
          比赛日程
        </h1>
        <p class="page-subtitle">实时比分 · 历史战绩 · 球员评分</p>
      </div>
      <div class="header-filters">
        <div class="filter-group">
          <el-select
            v-model="selectedStatus"
            placeholder="按状态"
            clearable
            size="large"
            class="filter-select"
          >
            <template #prefix>
              <el-icon><Filter /></el-icon>
            </template>
            <el-option
              v-for="status in matchStatuses"
              :key="status.value"
              :label="status.label"
              :value="status.value"
            />
          </el-select>
        </div>
        <div class="filter-group">
          <el-select
            v-model="selectedLeague"
            placeholder="按联赛"
            clearable
            size="large"
            class="filter-select"
          >
            <template #prefix>
              <el-icon><Tickets /></el-icon>
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
    </div>

    <!-- Match Stats Bar -->
    <div class="stats-bar" v-if="!loading && matches.length > 0">
      <div class="stat-pill stat-pill--live" v-if="liveCount > 0">
        <span class="pulse-dot"></span>
        <span>{{ liveCount }} 场直播中</span>
      </div>
      <div class="stat-pill stat-pill--pending" v-if="pendingCount > 0">
        <el-icon><Clock /></el-icon>
        <span>{{ pendingCount }} 场待开球</span>
      </div>
      <div class="stat-pill stat-pill--finished" v-if="finishedCount > 0">
        <el-icon><CircleCheck /></el-icon>
        <span>{{ finishedCount }} 场已结束</span>
      </div>
      <div class="result-count">共 {{ total }} 场比赛</div>
    </div>

    <!-- Loading Skeleton -->
    <div v-if="loading" class="matches-grid">
      <div v-for="i in 8" :key="i" class="match-card match-card--skeleton">
        <div class="skeleton-line skeleton-line--short"></div>
        <div class="skeleton-teams">
          <div class="skeleton-team"></div>
          <div class="skeleton-score"></div>
          <div class="skeleton-team"></div>
        </div>
        <div class="skeleton-line skeleton-line--full"></div>
      </div>
    </div>

    <!-- Matches Grid -->
    <div v-else-if="matches.length > 0" class="matches-grid">
      <div
        v-for="(match, index) in matches"
        :key="match.matchId"
        class="match-card"
        :style="{ animationDelay: `${Math.min(index, 12) * 50}ms` }"
        @click="router.push(`/matches/${match.matchId}`)"
      >
        <!-- Card Top: League + Status -->
        <div class="match-card__top">
          <div class="league-info">
            <span class="league-dot" :style="{ background: getLeagueColor(match.league) }"></span>
            <span class="league-name">{{ getLeagueNameCN(match.league) }}</span>
          </div>
          <div class="match-status" :class="getStatusClass(match.status)">
            <span v-if="match.status === 'IN_PROGRESS' || match.status === 'LIVE'" class="status-live-dot"></span>
            {{ getStatusLabel(match.status) }}
          </div>
        </div>

        <!-- Teams Row -->
        <div class="match-card__body">
          <!-- Home Team -->
          <div class="team-block team-block--home">
            <div class="team-logo-wrap">
              <img
                v-if="getClubLogo(match.homeClubId)"
                :src="getImageUrl(getClubLogo(match.homeClubId))"
                :alt="getClubName(match.homeClubId)"
                class="team-logo-img"
              />
              <span v-else class="team-initial">{{ getClubName(match.homeClubId)?.charAt(0) }}</span>
            </div>
            <span class="team-name">{{ getClubName(match.homeClubId) }}</span>
          </div>

          <!-- Score Center -->
          <div class="score-block">
            <div class="score-display" :class="{ 'score-display--live': match.status === 'IN_PROGRESS' || match.status === 'LIVE' }">
              <template v-if="match.homeScore !== null">
                <span class="score-num">{{ match.homeScore }}</span>
                <span class="score-sep">-</span>
                <span class="score-num">{{ match.awayScore }}</span>
              </template>
              <template v-else>
                <span class="score-vs">VS</span>
              </template>
            </div>
            <div class="time-info">
              <span v-if="match.liveMinute" class="live-minute">{{ match.liveMinute }}</span>
              <span v-else-if="match.status === 'FINISHED'" class="finished-time">全场</span>
              <span v-else class="scheduled-time">{{ formatTime(match.matchTime) }}</span>
            </div>
          </div>

          <!-- Away Team -->
          <div class="team-block team-block--away">
            <div class="team-logo-wrap">
              <img
                v-if="getClubLogo(match.awayClubId)"
                :src="getImageUrl(getClubLogo(match.awayClubId))"
                :alt="getClubName(match.awayClubId)"
                class="team-logo-img"
              />
              <span v-else class="team-initial">{{ getClubName(match.awayClubId)?.charAt(0) }}</span>
            </div>
            <span class="team-name">{{ getClubName(match.awayClubId) }}</span>
          </div>
        </div>

        <!-- Card Bottom: Venue / Round -->
        <div class="match-card__bottom" v-if="match.venue || match.round">
          <span class="venue-tag" v-if="match.venue">
            <el-icon><Location /></el-icon>
            {{ match.venue }}
          </span>
          <span class="round-tag" v-if="match.round">{{ match.round }}</span>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="empty-state">
      <div class="empty-visual">
        <svg width="80" height="80" viewBox="0 0 80 80" fill="none">
          <circle cx="40" cy="40" r="36" stroke="#7c3aed" stroke-width="2" stroke-dasharray="6 4" opacity="0.3"/>
          <path d="M28 40C28 40 32 32 40 32C48 32 52 40 52 40C52 40 48 48 40 48C32 48 28 40 28 40Z" fill="#7c3aed" opacity="0.2"/>
          <path d="M25 40C25 40 34 30 40 30C46 30 55 40 55 40" stroke="#7c3aed" stroke-width="2" stroke-linecap="round" opacity="0.3"/>
        </svg>
      </div>
      <h3 class="empty-title">暂无比赛数据</h3>
      <p class="empty-desc">尝试调整筛选条件，或查看其他联赛</p>
    </div>

    <!-- Pagination -->
    <div class="pagination-wrapper" v-if="total > pageSize">
      <el-pagination
        v-model:current-page="currentPage"
        :page-size="pageSize"
        :total="total"
        layout="prev, pager, next, jumper"
        background
        @current-change="fetchMatches"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Timer, Filter, Tickets, Clock, CircleCheck, Location } from '@element-plus/icons-vue'
import { matchApi, clubApi } from '@/api'

const router = useRouter()

const matches = ref<any[]>([])
const leagues = ref<string[]>([])
const selectedStatus = ref('')
const selectedLeague = ref('')
const currentPage = ref(1)
const pageSize = ref(20)
const total = ref(0)
const loading = ref(true)

const clubNameMap = ref<Record<number, string>>({})
const clubLogoMap = ref<Record<number, string>>({})

const liveCount = computed(() => matches.value.filter(m =>
  m.status === 'IN_PROGRESS' || m.status === 'LIVE'
).length)

const pendingCount = computed(() => matches.value.filter(m => m.status === 'PENDING').length)

const finishedCount = computed(() => matches.value.filter(m => m.status === 'FINISHED').length)

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

const leagueColors: Record<string, string> = {
  'La Liga': '#e8a317',
  'Premier League': '#6d28d9',
  'Bundesliga': '#d20515',
  'Serie A': '#024494',
  'Ligue 1': '#a855f7',
}

function getLeagueNameCN(league: string) {
  return leagueNameMap[league] || league
}

function getLeagueColor(league: string) {
  return leagueColors[league] || '#7c3aed'
}

function getStatusLabel(status: string) {
  return statusLabelMap[status] || status
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
  await fetchMatches()
})

async function fetchMatches() {
  loading.value = true
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
  } finally {
    loading.value = false
  }
}

function formatTime(time: string) {
  if (!time) return ''
  return new Date(time).toLocaleString('zh-CN', {
    month: 'short', day: 'numeric',
    hour: '2-digit', minute: '2-digit', hour12: false
  })
}
</script>

<style scoped lang="scss">
@use '@/styles/tokens' as *;

// --------------------------------------------------------------------------
// Page Header
// --------------------------------------------------------------------------

.page-container {
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
    color: $purple-primary;
    filter: drop-shadow(0 0 6px rgba($purple-primary, 0.5));
  }

  .page-subtitle {
    margin: 0;
    font-size: $font-size-sm;
    color: $text-muted;
  }
}

.header-filters {
  display: flex;
  gap: $space-3;
  flex-wrap: wrap;
}

.filter-select {
  width: 160px;

  :deep(.el-input__wrapper) {
    background: $surface-card !important;
    border-radius: $radius-md !important;
  }
}

// --------------------------------------------------------------------------
// Stats Bar
// --------------------------------------------------------------------------

.stats-bar {
  display: flex;
  align-items: center;
  gap: $space-3;
  margin-bottom: $space-5;
  padding: $space-3 $space-4;
  background: $surface-card;
  border: 1px solid $border-subtle;
  border-radius: $radius-lg;
}

.stat-pill {
  display: inline-flex;
  align-items: center;
  gap: $space-2;
  padding: $space-1 $space-3;
  border-radius: $radius-full;
  font-size: $font-size-xs;
  font-weight: $font-weight-semibold;
  letter-spacing: 0.3px;

  .el-icon {
    width: 14px;
    height: 14px;
  }

  &--live {
    background: rgba($danger, 0.1);
    color: $danger-light;
    border: 1px solid rgba($danger, 0.2);
  }

  &--pending {
    background: rgba($purple-primary, 0.1);
    color: $purple-light;
    border: 1px solid rgba($purple-primary, 0.2);
  }

  &--finished {
    background: rgba($success, 0.08);
    color: $success-light;
    border: 1px solid rgba($success, 0.15);
  }
}

.pulse-dot {
  width: 8px;
  height: 8px;
  background: $danger;
  border-radius: $radius-full;
  animation: pulseAnim 1.5s ease-in-out infinite;
  box-shadow: 0 0 6px rgba($danger, 0.8);
}

@keyframes pulseAnim {
  0%, 100% { opacity: 1; transform: scale(1); }
  50% { opacity: 0.5; transform: scale(0.8); }
}

.result-count {
  margin-left: auto;
  font-size: $font-size-sm;
  color: $text-muted;
}

// --------------------------------------------------------------------------
// Matches Grid
// --------------------------------------------------------------------------

.matches-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: $space-4;
  margin-bottom: $space-8;
}

// --------------------------------------------------------------------------
// Match Card
// --------------------------------------------------------------------------

.match-card {
  @include card($radius-xl);
  padding: $space-5;
  cursor: pointer;
  animation: cardIn 400ms $ease-out both;
  @include hover-lift($shadow-xl);
  @include focus-ring;
  position: relative;
  overflow: hidden;

  // Subtle gradient overlay
  &::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    height: 3px;
    background: linear-gradient(90deg, $purple-primary, $purple-light);
    opacity: 0;
    transition: opacity $duration-normal $ease-out;
  }

  &:hover::before {
    opacity: 1;
  }

  // Status color accent on left
  &.has-live::after {
    content: '';
    position: absolute;
    left: 0;
    top: 0;
    bottom: 0;
    width: 3px;
    background: linear-gradient(180deg, $danger, rgba($danger, 0.3));
  }

  &--skeleton {
    pointer-events: none;
    animation: none;
  }
}

@keyframes cardIn {
  from { opacity: 0; transform: translateY(16px); }
  to   { opacity: 1; transform: translateY(0); }
}

// Card Top
.match-card__top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: $space-4;
}

.league-info {
  display: flex;
  align-items: center;
  gap: $space-2;
}

.league-dot {
  width: 8px;
  height: 8px;
  border-radius: $radius-full;
  flex-shrink: 0;
  box-shadow: 0 0 6px currentColor;
}

.league-name {
  font-size: $font-size-xs;
  font-weight: $font-weight-semibold;
  color: $text-muted;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.match-status {
  display: inline-flex;
  align-items: center;
  gap: $space-1;
  padding: 2px $space-3;
  border-radius: $radius-full;
  font-size: $font-size-xs;
  font-weight: $font-weight-bold;
  letter-spacing: 0.3px;
  text-transform: uppercase;

  &.status--live {
    background: rgba($danger, 0.12);
    color: $danger-light;
    border: 1px solid rgba($danger, 0.25);
  }

  &.status--finished {
    background: rgba($success, 0.08);
    color: $success-light;
    border: 1px solid rgba($success, 0.15);
  }

  &.status--pending {
    background: rgba($purple-light, 0.06);
    color: $text-muted;
    border: 1px solid $border-subtle;
  }
}

.status-live-dot {
  width: 6px;
  height: 6px;
  background: $danger;
  border-radius: $radius-full;
  animation: pulseAnim 1.5s ease-in-out infinite;
  box-shadow: 0 0 6px rgba($danger, 0.8);
}

// Card Body
.match-card__body {
  display: grid;
  grid-template-columns: 1fr auto 1fr;
  align-items: center;
  gap: $space-3;
}

// Team Block
.team-block {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: $space-2;

  &--away {
    // Slight right alignment for visual balance
  }
}

.team-logo-wrap {
  width: 52px;
  height: 52px;
  border-radius: $radius-full;
  background: rgba($purple-primary, 0.06);
  border: 1.5px solid rgba($purple-primary, 0.12);
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  transition: all $duration-normal $ease-out;
  box-shadow: 0 0 0 4px rgba($purple-primary, 0.04);

  .match-card:hover & {
    border-color: rgba($purple-primary, 0.3);
    box-shadow: 0 0 0 4px rgba($purple-primary, 0.08),
                0 0 12px rgba($purple-primary, 0.15);
  }
}

.team-logo-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.team-initial {
  font-family: $font-display;
  font-size: $font-size-2xl;
  font-weight: $font-weight-bold;
  color: $purple-light;
}

.team-name {
  font-size: $font-size-sm;
  font-weight: $font-weight-medium;
  color: $text-secondary;
  text-align: center;
  max-width: 100px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  transition: color $duration-fast $ease-out;

  .match-card:hover & {
    color: $text-primary;
  }
}

// Score Block
.score-block {
  text-align: center;
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
    min-width: 32px;
    text-align: center;
  }

  .score-sep {
    font-size: $font-size-xl;
    color: $text-muted;
    font-weight: $font-weight-bold;
  }

  .score-vs {
    font-family: $font-display;
    font-size: $font-size-xl;
    color: $text-muted;
    letter-spacing: 2px;
  }

  &--live .score-num {
    @include text-gradient($gold-bright, $gold-dark);
  }
}

.time-info {
  margin-top: $space-2;
}

.live-minute {
  font-size: $font-size-xs;
  font-weight: $font-weight-bold;
  color: $danger-light;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  padding: 2px $space-2;
  background: rgba($danger, 0.1);
  border-radius: $radius-full;
}

.finished-time {
  font-size: $font-size-xs;
  color: $success-light;
  font-weight: $font-weight-semibold;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.scheduled-time {
  font-size: $font-size-xs;
  color: $text-muted;
}

// Card Bottom
.match-card__bottom {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: $space-4;
  padding-top: $space-3;
  border-top: 1px solid $border-subtle;
}

.venue-tag, .round-tag {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  font-size: $font-size-xs;
  color: $text-muted;

  .el-icon {
    width: 12px;
    height: 12px;
  }
}

.round-tag {
  margin-left: auto;
}

// --------------------------------------------------------------------------
// Skeleton
// --------------------------------------------------------------------------

.match-card--skeleton {
  .skeleton-line {
    height: 12px;
    border-radius: $radius-sm;
    background: linear-gradient(
      90deg,
      rgba($purple-light, 0.06) 0%,
      rgba($purple-light, 0.12) 50%,
      rgba($purple-light, 0.06) 100%
    );
    background-size: 200% 100%;
    animation: shimmer 1.5s ease-in-out infinite;
    margin-bottom: $space-4;

    &--short { width: 40%; }
    &--full { width: 100%; }
  }

  .skeleton-teams {
    display: grid;
    grid-template-columns: 1fr auto 1fr;
    gap: $space-3;
    align-items: center;
    margin-bottom: $space-4;
  }

  .skeleton-team {
    width: 52px;
    height: 52px;
    border-radius: $radius-full;
    margin: 0 auto;
    background: linear-gradient(
      90deg,
      rgba($purple-light, 0.06) 0%,
      rgba($purple-light, 0.12) 50%,
      rgba($purple-light, 0.06) 100%
    );
    background-size: 200% 100%;
    animation: shimmer 1.5s ease-in-out infinite;
  }

  .skeleton-score {
    width: 80px;
    height: 36px;
    border-radius: $radius-md;
    margin: 0 auto;
    background: linear-gradient(
      90deg,
      rgba($purple-light, 0.06) 0%,
      rgba($purple-light, 0.12) 50%,
      rgba($purple-light, 0.06) 100%
    );
    background-size: 200% 100%;
    animation: shimmer 1.5s ease-in-out infinite;
  }
}

// --------------------------------------------------------------------------
// Empty State
// --------------------------------------------------------------------------

.empty-state {
  text-align: center;
  padding: $space-16 $space-4;
  animation: fadeIn 400ms $ease-out;
}

.empty-visual {
  margin-bottom: $space-5;
  opacity: 0.6;
}

.empty-title {
  margin: 0 0 $space-2;
  font-family: $font-display;
  font-size: $font-size-xl;
  color: $text-secondary;
}

.empty-desc {
  margin: 0;
  font-size: $font-size-sm;
  color: $text-muted;
}

// --------------------------------------------------------------------------
// Pagination
// --------------------------------------------------------------------------

.pagination-wrapper {
  display: flex;
  justify-content: center;
  padding-top: $space-4;
}

// --------------------------------------------------------------------------
// Animations
// --------------------------------------------------------------------------

@keyframes shimmer {
  0%   { background-position: -200% 0; }
  100% { background-position: 200% 0; }
}

@keyframes fadeIn {
  from { opacity: 0; }
  to   { opacity: 1; }
}

@media (prefers-reduced-motion: reduce) {
  .pulse-dot, .status-live-dot {
    animation: none;
  }

  .match-card {
    animation: none;
  }

  .skeleton-line, .skeleton-team, .skeleton-score {
    animation: none;
    background: rgba($purple-light, 0.06);
  }
}
</style>
