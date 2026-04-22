<template>
  <div class="page-container">
    <div class="page-header">
      <h1>联赛积分榜</h1>
      <div class="header-actions">
        <el-select v-model="selectedLeague" placeholder="选择联赛" size="default" style="width: 240px;">
          <el-option v-for="league in leagues" :key="league" :label="getLeagueNameCN(league)" :value="league" />
        </el-select>
      </div>
    </div>

    <div class="standings-table">
      <el-table :data="standings" stripe style="width: 100%">
        <el-table-column prop="position" label="排名" width="70" align="center" />
        <el-table-column label="俱乐部" min-width="160">
          <template #default="{ row }">
            {{ getClubName(row.clubId) }}
          </template>
        </el-table-column>
        <el-table-column prop="played" label="场次" width="70" align="center" />
        <el-table-column prop="won" label="胜" width="60" align="center" />
        <el-table-column prop="drawn" label="平" width="60" align="center" />
        <el-table-column prop="lost" label="负" width="60" align="center" />
        <el-table-column prop="goalsFor" label="进球" width="70" align="center" />
        <el-table-column prop="goalsAgainst" label="失球" width="70" align="center" />
        <el-table-column prop="goalDiff" label="净胜球" width="80" align="center" />
        <el-table-column prop="points" label="积分" width="70" align="center">
          <template #default="{ row }">
            <span class="points-value">{{ row.points }}</span>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <div v-if="standings.length === 0" class="empty-state">暂无积分榜数据</div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch, onMounted } from 'vue'
import { clubApi, standingsApi } from '@/api'

const standings = ref<any[]>([])
const leagues = ref<string[]>([])
const selectedLeague = ref('')
const clubNameMap = ref<Record<number, string>>({})

function getClubName(clubId: number) {
  return clubNameMap.value[clubId] || `球队${clubId}`
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

watch(selectedLeague, () => {
  fetchStandings()
})

onMounted(async () => {
  try {
    const leaguesRes = await clubApi.getLeagues()
    leagues.value = leaguesRes.data.data || []

    const clubsRes = await clubApi.list({ page: 1, pageSize: 100 })
    const allClubs = clubsRes.data.data?.records || []
    allClubs.forEach((c: any) => {
      clubNameMap.value[c.clubId] = c.shortName || c.name
    })

    if (leagues.value.length > 0) {
      selectedLeague.value = leagues.value[0]
    }
  } catch (e) {
    console.error(e)
  }
})

async function fetchStandings() {
  if (!selectedLeague.value) return
  try {
    const res = await standingsApi.get({ league: selectedLeague.value })
    standings.value = res.data.data?.records || []
  } catch (e) {
    console.error(e)
  }
}
</script>

<style scoped lang="scss">
.standings-table {
  background: #ffffff;
  border-radius: 10px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);
  overflow: hidden;
}

.points-value {
  font-weight: 700;
  color: #1a56db;
}

.empty-state {
  text-align: center;
  padding: 40px;
  color: #737373;
  font-size: 14px;
  background: #ffffff;
  border-radius: 10px;
  margin-top: 16px;
}
</style>
