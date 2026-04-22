<template>
  <div class="page-container">
    <div class="page-header">
      <h1>联赛数据</h1>
      <div class="header-actions">
        <el-select v-model="selectedLeague" placeholder="选择联赛" size="default" style="width: 240px;">
          <el-option v-for="league in leagues" :key="league" :label="getLeagueNameCN(league)" :value="league" />
        </el-select>
      </div>
    </div>

    <div class="standings-tabs">
      <el-tabs v-model="activeTab" type="border-card">
        <el-tab-pane label="积分榜" name="standings">
          <el-table :data="standings" stripe style="width: 100%">
            <el-table-column prop="position" label="排名" width="70" align="center" />
            <el-table-column label="俱乐部" min-width="160">
              <template #default="{ row }">{{ getClubName(row.clubId) }}</template>
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
          <div v-if="standings.length === 0" class="empty-state">暂无积分榜数据</div>
        </el-tab-pane>

        <el-tab-pane label="射手榜" name="scorers">
          <el-table :data="scorers" stripe style="width: 100%">
            <el-table-column label="排名" width="70" align="center">
              <template #default="{ row }">{{ row.rank }}</template>
            </el-table-column>
            <el-table-column label="球员" min-width="160">
              <template #default="{ row }">
                <span>{{ row.playerNameCn || row.playerName }}</span>
                <span v-if="row.clubShort" class="club-tag">{{ row.clubShort }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="position" label="位置" width="80" align="center">
              <template #default="{ row }">{{ positionMap[row.position] || row.position }}</template>
            </el-table-column>
            <el-table-column prop="appearances" label="出场" width="70" align="center" />
            <el-table-column prop="goals" label="进球" width="80" align="center">
              <template #default="{ row }"><span class="highlight-value">{{ row.goals }}</span></template>
            </el-table-column>
            <el-table-column prop="assists" label="助攻" width="70" align="center" />
          </el-table>
          <div v-if="scorers.length === 0" class="empty-state">暂无射手榜数据</div>
        </el-tab-pane>

        <el-tab-pane label="助攻榜" name="assists">
          <el-table :data="assists" stripe style="width: 100%">
            <el-table-column label="排名" width="70" align="center">
              <template #default="{ row }">{{ row.rank }}</template>
            </el-table-column>
            <el-table-column label="球员" min-width="160">
              <template #default="{ row }">
                <span>{{ row.playerNameCn || row.playerName }}</span>
                <span v-if="row.clubShort" class="club-tag">{{ row.clubShort }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="position" label="位置" width="80" align="center">
              <template #default="{ row }">{{ positionMap[row.position] || row.position }}</template>
            </el-table-column>
            <el-table-column prop="appearances" label="出场" width="70" align="center" />
            <el-table-column prop="assists" label="助攻" width="80" align="center">
              <template #default="{ row }"><span class="highlight-value">{{ row.assists }}</span></template>
            </el-table-column>
            <el-table-column prop="goals" label="进球" width="70" align="center" />
          </el-table>
          <div v-if="assists.length === 0" class="empty-state">暂无助攻榜数据</div>
        </el-tab-pane>

        <el-tab-pane label="黄牌榜" name="yellowCards">
          <el-table :data="yellowCards" stripe style="width: 100%">
            <el-table-column label="排名" width="70" align="center">
              <template #default="{ row }">{{ row.rank }}</template>
            </el-table-column>
            <el-table-column label="球员" min-width="160">
              <template #default="{ row }">
                <span>{{ row.playerNameCn || row.playerName }}</span>
                <span v-if="row.clubShort" class="club-tag">{{ row.clubShort }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="position" label="位置" width="80" align="center">
              <template #default="{ row }">{{ positionMap[row.position] || row.position }}</template>
            </el-table-column>
            <el-table-column prop="appearances" label="出场" width="70" align="center" />
            <el-table-column prop="yellowCards" label="黄牌" width="80" align="center">
              <template #default="{ row }"><span class="yellow-value">{{ row.yellowCards }}</span></template>
            </el-table-column>
          </el-table>
          <div v-if="yellowCards.length === 0" class="empty-state">暂无黄牌榜数据</div>
        </el-tab-pane>

        <el-tab-pane label="红牌榜" name="redCards">
          <el-table :data="redCards" stripe style="width: 100%">
            <el-table-column label="排名" width="70" align="center">
              <template #default="{ row }">{{ row.rank }}</template>
            </el-table-column>
            <el-table-column label="球员" min-width="160">
              <template #default="{ row }">
                <span>{{ row.playerNameCn || row.playerName }}</span>
                <span v-if="row.clubShort" class="club-tag">{{ row.clubShort }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="position" label="位置" width="80" align="center">
              <template #default="{ row }">{{ positionMap[row.position] || row.position }}</template>
            </el-table-column>
            <el-table-column prop="appearances" label="出场" width="70" align="center" />
            <el-table-column prop="redCards" label="红牌" width="80" align="center">
              <template #default="{ row }"><span class="red-value">{{ row.redCards }}</span></template>
            </el-table-column>
          </el-table>
          <div v-if="redCards.length === 0" class="empty-state">暂无红牌榜数据</div>
        </el-tab-pane>
      </el-tabs>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch, onMounted } from 'vue'
import { clubApi, standingsApi } from '@/api'

const activeTab = ref('standings')
const standings = ref<any[]>([])
const scorers = ref<any[]>([])
const assists = ref<any[]>([])
const yellowCards = ref<any[]>([])
const redCards = ref<any[]>([])
const leagues = ref<string[]>([])
const selectedLeague = ref('')
const clubNameMap = ref<Record<number, string>>({})

const positionMap: Record<string, string> = { GK: '门将', DF: '后卫', MF: '中场', FW: '前锋' }

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
  fetchAllData()
})

watch(activeTab, () => {
  fetchAllData()
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

async function fetchAllData() {
  if (!selectedLeague.value) return
  fetchStandings()
  if (activeTab.value === 'scorers') fetchScorers()
  if (activeTab.value === 'assists') fetchAssists()
  if (activeTab.value === 'yellowCards') fetchYellowCards()
  if (activeTab.value === 'redCards') fetchRedCards()
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
.standings-tabs {
  background: #ffffff;
  border-radius: 10px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);
  overflow: hidden;
}

.points-value {
  font-weight: 700;
  color: #1a56db;
}

.highlight-value {
  font-weight: 700;
  color: #1a56db;
}

.yellow-value {
  font-weight: 700;
  color: #d97706;
}

.red-value {
  font-weight: 700;
  color: #dc2626;
}

.club-tag {
  display: inline-block;
  margin-left: 8px;
  padding: 1px 6px;
  background: #f3f4f6;
  border-radius: 4px;
  font-size: 12px;
  color: #6b7280;
}

.empty-state {
  text-align: center;
  padding: 40px;
  color: #737373;
  font-size: 14px;
}
</style>
