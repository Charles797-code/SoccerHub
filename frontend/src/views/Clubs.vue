<template>
  <div class="page-container">
    <div class="page-header">
      <h1>足球俱乐部</h1>
      <div class="header-actions">
        <el-select v-model="selectedLeague" placeholder="按联赛筛选" clearable size="default"
          style="width: 200px;">
          <el-option v-for="league in leagues" :key="league" :label="getLeagueNameCN(league)" :value="league" />
        </el-select>
      </div>
    </div>

    <div class="card-grid">
      <div v-for="club in clubs" :key="club.clubId" class="club-card" @click="goToClub(club.clubId)">
        <div class="club-header">
          <img v-if="club.logoUrl" :src="getClubLogoUrl(club.logoUrl)" :alt="club.name" />
          <span v-else>{{ club.shortName?.charAt(0) || club.name?.charAt(0) }}</span>
        </div>
        <div class="club-body">
          <h3>{{ club.shortName || club.name }}</h3>
          <span class="league-badge">{{ getLeagueNameCN(club.league) }}</span>
          <div class="club-info">
            <div class="info-row">
              <el-icon><Location /></el-icon>
              <span>{{ club.city }}, {{ club.country }}</span>
            </div>
            <div class="info-row">
              <el-icon><OfficeBuilding /></el-icon>
              <span>{{ club.stadium }}</span>
            </div>
          </div>
          <div class="club-stats">
            <div class="stat">
              <span class="stat-value">{{ club.totalScore != null ? Number(club.totalScore).toFixed(1) : '-' }}</span>
              <span class="stat-label">评分</span>
            </div>
            <div class="stat">
              <span class="stat-value">{{ club.stadiumCapacity != null ? club.stadiumCapacity.toLocaleString() : '-' }}</span>
              <span class="stat-label">容量</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="pagination-wrapper">
      <el-pagination v-model:current-page="currentPage" :page-size="pageSize" :total="total"
        layout="prev, pager, next" @current-change="fetchClubs" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { Location, OfficeBuilding } from '@element-plus/icons-vue'
import { clubApi } from '@/api'

const router = useRouter()
const route = useRoute()

const clubs = ref<any[]>([])
const leagues = ref<string[]>([])
const selectedLeague = ref('')
const currentPage = ref(1)
const pageSize = ref(20)
const total = ref(0)

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

watch(selectedLeague, () => {
  currentPage.value = 1
  fetchClubs()
})

onMounted(async () => {
  try {
    const leaguesRes = await clubApi.getLeagues()
    leagues.value = leaguesRes.data.data || []
  } catch (e) {
    console.error(e)
  }

  if (route.query.league) {
    selectedLeague.value = route.query.league as string
  }

  fetchClubs()
})

async function fetchClubs() {
  try {
    const res = await clubApi.list({
      page: currentPage.value,
      pageSize: pageSize.value,
      league: selectedLeague.value || undefined
    })
    clubs.value = res.data.data?.records || []
    total.value = res.data.data?.total || 0
  } catch (e) {
    console.error(e)
  }
}

function goToClub(clubId: number) {
  router.push(`/clubs/${clubId}`)
}

function getClubLogoUrl(url: string) {
  if (!url) return ''
  if (url.startsWith('http://') || url.startsWith('https://')) return url
  return url
}
</script>

<style scoped lang="scss">
.club-info {
  margin-top: 10px;

  .info-row {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 13px;
    color: #737373;
    margin-bottom: 4px;
  }
}

.club-stats {
  display: flex;
  justify-content: space-around;
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px solid #f0f0f0;

  .stat {
    text-align: center;

    .stat-value {
      display: block;
      font-size: 16px;
      font-weight: 700;
      color: #1a56db;
    }

    .stat-label {
      font-size: 11px;
      color: #a3a3a3;
    }
  }
}

.pagination-wrapper {
  display: flex;
  justify-content: center;
  margin-top: 24px;
}

.club-header {
  height: 80px;
  background: linear-gradient(135deg, #1a56db, #3b82f6);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 36px;

  img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }

  span {
    color: white;
  }
}
</style>
