<template>
  <div class="mobile-matches">
    <!-- Status Tabs -->
    <div class="status-tabs">
      <div
        v-for="tab in tabs"
        :key="tab.value"
        class="tab"
        :class="{ active: selectedStatus === tab.value }"
        @click="selectStatus(tab.value)"
      >
        {{ tab.label }}
      </div>
    </div>

    <!-- League Filter -->
    <div class="filter-bar">
      <select v-model="selectedLeague" class="league-select">
        <option value="">全部联赛</option>
        <option v-for="l in leagues" :key="l" :value="l">{{ getLeagueShort(l) }}</option>
      </select>
    </div>

    <!-- Matches List -->
    <div class="matches-list" v-if="filteredMatches.length > 0">
      <div
        v-for="match in filteredMatches"
        :key="match.matchId"
        class="match-card"
        @click="router.push(`/m/matches/${match.matchId}`)"
      >
        <div class="match-header">
          <span class="league">{{ getLeagueShort(match.league) }}</span>
          <span class="status" :class="getStatusClass(match.status)">
            {{ getStatusLabel(match.status) }}
          </span>
        </div>
        <div class="match-teams">
          <div class="team">
            <img
              v-if="getClubLogo(match.homeClubId)"
              :src="getImageUrl(getClubLogo(match.homeClubId))"
              :alt="getClubName(match.homeClubId)"
            />
            <span v-else class="team-initial">{{ getClubName(match.homeClubId)?.charAt(0) }}</span>
            <span class="team-name">{{ getClubName(match.homeClubId) }}</span>
          </div>
          <div class="score-box">
            <span v-if="match.homeScore !== null" class="score">{{ match.homeScore }} - {{ match.awayScore }}</span>
            <span v-else class="time">{{ formatTime(match.matchTime) }}</span>
            <span v-if="match.liveMinute" class="live-minute">{{ match.liveMinute }}</span>
          </div>
          <div class="team team--away">
            <span class="team-name">{{ getClubName(match.awayClubId) }}</span>
            <img
              v-if="getClubLogo(match.awayClubId)"
              :src="getImageUrl(getClubLogo(match.awayClubId))"
              :alt="getClubName(match.awayClubId)"
            />
            <span v-else class="team-initial">{{ getClubName(match.awayClubId)?.charAt(0) }}</span>
          </div>
        </div>
        <div class="match-footer">
          <span class="round" v-if="match.round">{{ match.round }}</span>
          <span class="venue" v-if="match.venue">{{ match.venue }}</span>
        </div>
      </div>
    </div>
    <div v-else class="empty">
      <Timer class="empty-icon" />
      <p>暂无比赛</p>
    </div>

    <!-- Load More -->
    <div v-if="hasMore && filteredMatches.length > 0" class="load-more" @click="loadMore">
      加载更多
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Timer } from '@element-plus/icons-vue'
import { matchApi, clubApi } from '@/api'

const router = useRouter()

const matches = ref<any[]>([])
const clubs = ref<any[]>([])
const selectedStatus = ref('')
const selectedLeague = ref('')
const page = ref(1)
const hasMore = ref(true)

const clubNameMap = ref<Record<number, string>>({})
const clubLogoMap = ref<Record<number, string>>({})

const leagueNameMap: Record<string, string> = {
  'La Liga': '西甲',
  'Premier League': '英超',
  'Bundesliga': '德甲',
  'Serie A': '意甲',
  'Ligue 1': '法甲'
}

const tabs = [
  { label: '全部', value: '' },
  { label: '直播中', value: 'LIVE' },
  { label: '今日', value: 'TODAY' },
  { label: '已结束', value: 'FINISHED' },
]

const leagues = computed(() => {
  const set = new Set(matches.value.map((m: any) => m.league))
  return Array.from(set)
})

function getLeagueShort(league: string) {
  return leagueNameMap[league] || league || ''
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
    month: 'short', day: 'numeric',
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

function selectStatus(status: string) {
  selectedStatus.value = status
  page.value = 1
  fetchMatches()
}

async function fetchMatches() {
  try {
    let res
    if (selectedStatus.value === 'LIVE') {
      res = await matchApi.getLive()
      matches.value = res.data.data || []
      hasMore.value = false
    } else if (selectedStatus.value === 'TODAY') {
      res = await matchApi.getToday()
      matches.value = res.data.data || []
      hasMore.value = false
    } else {
      res = await matchApi.list({ page: page.value, pageSize: 20 })
      if (page.value === 1) {
        matches.value = res.data.data?.records || []
      } else {
        matches.value = [...matches.value, ...(res.data.data?.records || [])]
      }
      hasMore.value = (res.data.data?.records?.length || 0) >= 20
    }
  } catch (e) {
    console.error('加载比赛失败', e)
  }
}

async function fetchClubs() {
  try {
    const res = await clubApi.list({ page: 1, pageSize: 100 })
    clubs.value = res.data.data?.records || []
    clubs.value.forEach((c: any) => {
      clubNameMap.value[c.clubId] = c.shortName || c.name
      clubLogoMap.value[c.clubId] = c.logoUrl || c.logo || ''
    })
  } catch (e) {
    console.error('加载俱乐部失败', e)
  }
}

function loadMore() {
  page.value++
  fetchMatches()
}

const filteredMatches = computed(() => {
  let result = matches.value
  if (selectedLeague.value) {
    result = result.filter((m: any) => m.league === selectedLeague.value)
  }
  if (selectedStatus.value === 'FINISHED') {
    result = result.filter((m: any) => m.status === 'FINISHED')
  }
  return result
})

onMounted(async () => {
  await fetchClubs()
  await fetchMatches()
})
</script>

<style scoped lang="scss">
.mobile-matches {
  padding: 16px;
}

.status-tabs {
  display: flex;
  gap: 8px;
  margin-bottom: 12px;
}

.tab {
  padding: 8px 16px;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 20px;
  font-size: 13px;
  color: rgba(255, 255, 255, 0.6);
  cursor: pointer;
  transition: all 0.2s;

  &.active {
    background: #7c3aed;
    color: #fff;
  }
}

.filter-bar {
  margin-bottom: 16px;
}

.league-select {
  width: 100%;
  padding: 10px 14px;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 10px;
  color: #fff;
  font-size: 14px;
  outline: none;

  option {
    background: #1a1a2e;
    color: #fff;
  }
}

.matches-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.match-card {
  background: rgba(255, 255, 255, 0.03);
  border-radius: 12px;
  padding: 14px;
  cursor: pointer;
  transition: all 0.2s;

  &:active {
    background: rgba(255, 255, 255, 0.06);
  }
}

.match-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;

  .league {
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
    width: 40px;
    height: 40px;
    border-radius: 50%;
    object-fit: cover;
  }

  .team-initial {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    background: rgba(124, 58, 237, 0.2);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 16px;
    font-weight: 600;
    color: #a78bfa;
  }

  .team-name {
    font-size: 12px;
    color: rgba(255, 255, 255, 0.8);
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

.score-box {
  text-align: center;
  flex-shrink: 0;

  .score {
    font-size: 22px;
    font-weight: 700;
    color: #fff;
  }

  .time {
    font-size: 12px;
    color: rgba(255, 255, 255, 0.5);
  }

  .live-minute {
    display: block;
    font-size: 11px;
    color: #ef4444;
    font-weight: 600;
    margin-top: 4px;
  }
}

.match-footer {
  display: flex;
  justify-content: center;
  gap: 12px;
  margin-top: 10px;
  padding-top: 10px;
  border-top: 1px solid rgba(255, 255, 255, 0.05);

  .round, .venue {
    font-size: 11px;
    color: rgba(255, 255, 255, 0.4);
  }
}

.empty {
  text-align: center;
  padding: 48px 16px;
  color: rgba(255, 255, 255, 0.4);

  .empty-icon {
    font-size: 40px;
    margin-bottom: 12px;
    opacity: 0.5;
  }
}

.load-more {
  text-align: center;
  padding: 16px;
  color: #7c3aed;
  font-size: 14px;
  cursor: pointer;
}
</style>
