<template>
  <div class="page-container">
    <div class="page-header">
      <h1>超级管理后台</h1>
    </div>

    <div class="admin-tabs">
      <el-tabs v-model="activeTab" type="border-card">
        <el-tab-pane label="系统统计" name="stats">
          <div class="stats-grid">
            <div class="stat-card">
              <span class="stat-value">{{ stats.totalUsers ?? 0 }}</span>
              <span class="stat-label">总用户数</span>
            </div>
            <div class="stat-card">
              <span class="stat-value">{{ stats.totalClubs ?? 0 }}</span>
              <span class="stat-label">总俱乐部数</span>
            </div>
            <div class="stat-card">
              <span class="stat-value">{{ stats.totalPlayers ?? 0 }}</span>
              <span class="stat-label">总球员数</span>
            </div>
            <div class="stat-card">
              <span class="stat-value">{{ stats.totalMatches ?? 0 }}</span>
              <span class="stat-label">总比赛数</span>
            </div>
          </div>
        </el-tab-pane>

        <el-tab-pane label="用户管理" name="users">
          <div class="toolbar">
            <el-select v-model="userFilterRole" placeholder="角色筛选" clearable style="width:150px" @change="fetchUsers">
              <el-option label="超级管理员" value="SUPER_ADMIN" />
              <el-option label="俱乐部管理员" value="CLUB_ADMIN" />
              <el-option label="球迷" value="FAN" />
            </el-select>
            <el-input v-model="userKeyword" placeholder="搜索用户名/昵称" clearable style="width:200px" @keyup.enter="fetchUsers" />
            <el-button type="primary" @click="fetchUsers">搜索</el-button>
          </div>
          <el-table :data="users" stripe>
            <el-table-column prop="userId" label="ID" width="70" />
            <el-table-column prop="username" label="用户名" width="130" />
            <el-table-column prop="nickname" label="昵称" width="130" />
            <el-table-column prop="role" label="角色" width="120">
              <template #default="{ row }">
                <el-select v-model="row.role" size="small" @change="handleRoleChange(row.userId, row.role)">
                  <el-option label="超级管理员" value="SUPER_ADMIN" />
                  <el-option label="俱乐部管理员" value="CLUB_ADMIN" />
                  <el-option label="球迷" value="FAN" />
                </el-select>
              </template>
            </el-table-column>
            <el-table-column prop="managedClubId" label="管理俱乐部" width="130">
              <template #default="{ row }">
                <el-select v-if="row.role === 'CLUB_ADMIN'" v-model="row.managedClubId" size="small" placeholder="分配俱乐部" @change="handleAssignClub(row.userId, row.managedClubId)">
                  <el-option v-for="c in allClubs" :key="c.clubId" :label="c.shortName || c.name" :value="c.clubId" />
                </el-select>
                <span v-else>-</span>
              </template>
            </el-table-column>
            <el-table-column prop="status" label="状态" width="90">
              <template #default="{ row }">
                <el-tag :type="row.status === 'ACTIVE' ? 'success' : 'danger'" size="small">
                  {{ row.status === 'ACTIVE' ? '正常' : '禁用' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="100">
              <template #default="{ row }">
                <el-button v-if="row.status === 'ACTIVE'" type="danger" size="small" @click="toggleUserStatus(row.userId, 'DISABLED')">禁用</el-button>
                <el-button v-else type="success" size="small" @click="toggleUserStatus(row.userId, 'ACTIVE')">启用</el-button>
              </template>
            </el-table-column>
          </el-table>
          <div class="pagination-wrapper">
            <el-pagination v-model:current-page="userPage" :page-size="pageSize" :total="userTotal" layout="prev, pager, next" @current-change="fetchUsers" />
          </div>
        </el-tab-pane>

        <el-tab-pane label="比赛管理" name="matches">
          <div class="toolbar">
            <el-select v-model="matchFilterLeague" placeholder="联赛筛选" clearable style="width:160px" @change="fetchMatches">
              <el-option label="Premier League" value="Premier League" />
              <el-option label="La Liga" value="La Liga" />
              <el-option label="Bundesliga" value="Bundesliga" />
              <el-option label="Serie A" value="Serie A" />
              <el-option label="Ligue 1" value="Ligue 1" />
            </el-select>
            <el-select v-model="matchFilterStatus" placeholder="状态筛选" clearable style="width:120px" @change="fetchMatches">
              <el-option label="未开始" value="PENDING" />
              <el-option label="进行中" value="IN_PROGRESS" />
              <el-option label="已结束" value="FINISHED" />
            </el-select>
            <el-button type="primary" @click="openMatchDialog()">新增比赛</el-button>
          </div>
          <el-table :data="matches" stripe>
            <el-table-column prop="matchId" label="ID" width="90" />
            <el-table-column label="主队" width="130">
              <template #default="{ row }">{{ getClubName(row.homeClubId) }}</template>
            </el-table-column>
            <el-table-column label="比分" width="80">
              <template #default="{ row }">{{ row.homeScore ?? '-' }} : {{ row.awayScore ?? '-' }}</template>
            </el-table-column>
            <el-table-column label="客队" width="130">
              <template #default="{ row }">{{ getClubName(row.awayClubId) }}</template>
            </el-table-column>
            <el-table-column prop="league" label="联赛" width="130" />
            <el-table-column prop="status" label="状态" width="90">
              <template #default="{ row }">
                <el-tag :type="matchStatusType(row.status)" size="small">{{ matchStatusMap[row.status] || row.status }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="比赛时间" width="160">
              <template #default="{ row }">{{ formatTime(row.matchTime) }}</template>
            </el-table-column>
            <el-table-column label="操作" width="150">
              <template #default="{ row }">
                <el-button size="small" @click="openMatchDialog(row)">编辑</el-button>
                <el-button type="danger" size="small" @click="handleDeleteMatch(row.matchId)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
          <div class="pagination-wrapper">
            <el-pagination v-model:current-page="matchPage" :page-size="pageSize" :total="matchTotal" layout="prev, pager, next" @current-change="fetchMatches" />
          </div>
        </el-tab-pane>

        <el-tab-pane label="转会管理" name="transfers">
          <div class="toolbar">
            <el-select v-model="transferFilterType" placeholder="转会类型" clearable style="width:120px" @change="fetchTransfers">
              <el-option label="转入" value="IN" />
              <el-option label="转出" value="OUT" />
              <el-option label="租借" value="LOAN" />
              <el-option label="自由身" value="FREE" />
            </el-select>
            <el-button type="primary" @click="openTransferDialog()">新增转会</el-button>
          </div>
          <el-table :data="transfers" stripe>
            <el-table-column prop="logId" label="ID" width="70" />
            <el-table-column label="球员" width="130">
              <template #default="{ row }">{{ getPlayerName(row.playerId) }}</template>
            </el-table-column>
            <el-table-column label="原俱乐部" width="130">
              <template #default="{ row }">{{ row.oldClubId ? getClubName(row.oldClubId) : '无' }}</template>
            </el-table-column>
            <el-table-column label="新俱乐部" width="130">
              <template #default="{ row }">{{ row.newClubId ? getClubName(row.newClubId) : '无' }}</template>
            </el-table-column>
            <el-table-column prop="transferType" label="类型" width="80">
              <template #default="{ row }">{{ transferTypeMap[row.transferType] || row.transferType }}</template>
            </el-table-column>
            <el-table-column label="转会费" width="100">
              <template #default="{ row }">{{ row.transferFee ? (row.transferFee / 10000).toFixed(0) + '万' : '-' }}</template>
            </el-table-column>
            <el-table-column prop="season" label="赛季" width="80" />
            <el-table-column label="操作时间" width="160">
              <template #default="{ row }">{{ formatTime(row.actionTime) }}</template>
            </el-table-column>
            <el-table-column label="操作" width="80">
              <template #default="{ row }">
                <el-button type="danger" size="small" @click="handleDeleteTransfer(row.logId)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
          <div class="pagination-wrapper">
            <el-pagination v-model:current-page="transferPage" :page-size="pageSize" :total="transferTotal" layout="prev, pager, next" @current-change="fetchTransfers" />
          </div>
        </el-tab-pane>

        <el-tab-pane label="俱乐部管理" name="clubs">
          <div class="toolbar">
            <el-button type="primary" @click="openClubDialog()">新增俱乐部</el-button>
          </div>
          <el-table :data="clubs" stripe>
            <el-table-column prop="clubId" label="ID" width="70" />
            <el-table-column prop="name" label="名称" min-width="150" />
            <el-table-column prop="shortName" label="简称" width="100" />
            <el-table-column prop="league" label="联赛" width="140" />
            <el-table-column prop="city" label="城市" width="100" />
            <el-table-column prop="stadium" label="主场" width="140" />
            <el-table-column label="操作" width="150">
              <template #default="{ row }">
                <el-button size="small" @click="openClubDialog(row)">编辑</el-button>
                <el-button type="danger" size="small" @click="handleDeleteClub(row.clubId)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
          <div class="pagination-wrapper">
            <el-pagination v-model:current-page="clubPage" :page-size="pageSize" :total="clubTotal" layout="prev, pager, next" @current-change="fetchClubs" />
          </div>
        </el-tab-pane>

        <el-tab-pane label="球员管理" name="players">
          <div class="toolbar">
            <el-select v-model="playerFilterClub" placeholder="俱乐部筛选" clearable style="width:160px" @change="fetchPlayers">
              <el-option v-for="c in allClubs" :key="c.clubId" :label="c.shortName || c.name" :value="c.clubId" />
            </el-select>
            <el-input v-model="playerKeyword" placeholder="搜索球员" clearable style="width:180px" @keyup.enter="fetchPlayers" />
            <el-button type="primary" @click="fetchPlayers">搜索</el-button>
            <el-button type="success" @click="openPlayerDialog()">新增球员</el-button>
          </div>
          <el-table :data="players" stripe>
            <el-table-column prop="playerId" label="ID" width="70" />
            <el-table-column prop="nameCn" label="中文名" width="100" />
            <el-table-column prop="name" label="英文名" width="120" />
            <el-table-column label="俱乐部" width="120">
              <template #default="{ row }">{{ getClubName(row.clubId) }}</template>
            </el-table-column>
            <el-table-column prop="position" label="位置" width="70" />
            <el-table-column prop="jerseyNumber" label="号码" width="60" />
            <el-table-column prop="status" label="状态" width="80">
              <template #default="{ row }">
                <el-tag :type="row.status === 'ACTIVE' ? 'success' : 'info'" size="small">{{ playerStatusMap[row.status] || row.status }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="avgScore" label="评分" width="70" />
            <el-table-column label="操作" width="150">
              <template #default="{ row }">
                <el-button size="small" @click="openPlayerDialog(row)">编辑</el-button>
                <el-button type="danger" size="small" @click="handleDeletePlayer(row.playerId)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
          <div class="pagination-wrapper">
            <el-pagination v-model:current-page="playerPage" :page-size="pageSize" :total="playerTotal" layout="prev, pager, next" @current-change="fetchPlayers" />
          </div>
        </el-tab-pane>
      </el-tabs>
    </div>

    <el-dialog v-model="matchDialogVisible" :title="matchForm.matchId ? '编辑比赛' : '新增比赛'" width="550px">
      <el-form :model="matchForm" label-width="90px">
        <el-form-item label="比赛ID" v-if="!matchForm.matchId">
          <el-input v-model="matchForm.matchId" placeholder="如 EPL007" />
        </el-form-item>
        <el-form-item label="主队">
          <el-select v-model="matchForm.homeClubId" placeholder="选择主队" style="width:100%">
            <el-option v-for="c in allClubs" :key="c.clubId" :label="c.shortName || c.name" :value="c.clubId" />
          </el-select>
        </el-form-item>
        <el-form-item label="客队">
          <el-select v-model="matchForm.awayClubId" placeholder="选择客队" style="width:100%">
            <el-option v-for="c in allClubs" :key="c.clubId" :label="c.shortName || c.name" :value="c.clubId" />
          </el-select>
        </el-form-item>
        <el-form-item label="比赛时间">
          <el-date-picker v-model="matchForm.matchTime" type="datetime" placeholder="选择时间" style="width:100%" />
        </el-form-item>
        <el-form-item label="联赛">
          <el-input v-model="matchForm.league" />
        </el-form-item>
        <el-form-item label="赛季">
          <el-input v-model="matchForm.season" placeholder="如 2024-2025" />
        </el-form-item>
        <el-form-item label="轮次">
          <el-input v-model="matchForm.round" />
        </el-form-item>
        <el-form-item label="场地">
          <el-input v-model="matchForm.venue" />
        </el-form-item>
        <el-form-item label="裁判">
          <el-input v-model="matchForm.referee" />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="matchForm.status" style="width:100%">
            <el-option label="未开始" value="PENDING" />
            <el-option label="进行中" value="IN_PROGRESS" />
            <el-option label="已结束" value="FINISHED" />
          </el-select>
        </el-form-item>
        <el-form-item label="主队比分" v-if="matchForm.status !== 'PENDING'">
          <el-input-number v-model="matchForm.homeScore" :min="0" />
        </el-form-item>
        <el-form-item label="客队比分" v-if="matchForm.status !== 'PENDING'">
          <el-input-number v-model="matchForm.awayScore" :min="0" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="matchDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSaveMatch">保存</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="transferDialogVisible" title="新增转会" width="500px">
      <el-form :model="transferForm" label-width="90px">
        <el-form-item label="球员">
          <el-select v-model="transferForm.playerId" placeholder="选择球员" filterable style="width:100%" @change="onTransferPlayerChange">
            <el-option v-for="p in allPlayers" :key="p.playerId" :label="p.nameCn || p.name" :value="p.playerId" />
          </el-select>
        </el-form-item>
        <el-form-item label="新俱乐部">
          <el-select v-model="transferForm.newClubId" placeholder="选择新俱乐部" style="width:100%">
            <el-option v-for="c in allClubs" :key="c.clubId" :label="c.shortName || c.name" :value="c.clubId" />
          </el-select>
        </el-form-item>
        <el-form-item label="转会类型">
          <el-select v-model="transferForm.transferType" style="width:100%">
            <el-option label="转入" value="IN" />
            <el-option label="转出" value="OUT" />
            <el-option label="租借" value="LOAN" />
            <el-option label="自由身" value="FREE" />
          </el-select>
        </el-form-item>
        <el-form-item label="转会费">
          <el-input-number v-model="transferForm.transferFee" :min="0" :step="1000000" style="width:100%" />
        </el-form-item>
        <el-form-item label="赛季">
          <el-input v-model="transferForm.season" placeholder="如 2024-2025" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="transferForm.notes" type="textarea" :rows="2" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="transferDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSaveTransfer">确认转会</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="clubDialogVisible" :title="clubForm.clubId ? '编辑俱乐部' : '新增俱乐部'" width="550px">
      <el-form :model="clubForm" label-width="90px">
        <el-form-item label="俱乐部Logo">
          <ImageUpload v-model="clubForm.logoUrl" placeholder="上传Logo" alt="俱乐部Logo" />
        </el-form-item>
        <el-form-item label="名称">
          <el-input v-model="clubForm.name" />
        </el-form-item>
        <el-form-item label="简称">
          <el-input v-model="clubForm.shortName" />
        </el-form-item>
        <el-form-item label="联赛">
          <el-input v-model="clubForm.league" />
        </el-form-item>
        <el-form-item label="城市">
          <el-input v-model="clubForm.city" />
        </el-form-item>
        <el-form-item label="国家">
          <el-input v-model="clubForm.country" />
        </el-form-item>
        <el-form-item label="主场">
          <el-input v-model="clubForm.stadium" />
        </el-form-item>
        <el-form-item label="容量">
          <el-input-number v-model="clubForm.stadiumCapacity" :min="0" />
        </el-form-item>
        <el-form-item label="简介">
          <el-input v-model="clubForm.description" type="textarea" :rows="3" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="clubDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSaveClub">保存</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="playerDialogVisible" :title="playerForm.playerId ? '编辑球员' : '新增球员'" width="550px">
      <el-form :model="playerForm" label-width="90px">
        <el-form-item label="球员头像">
          <ImageUpload v-model="playerForm.avatarUrl" placeholder="上传头像" alt="球员头像" />
        </el-form-item>
        <el-form-item label="英文名">
          <el-input v-model="playerForm.name" />
        </el-form-item>
        <el-form-item label="中文名">
          <el-input v-model="playerForm.nameCn" />
        </el-form-item>
        <el-form-item label="俱乐部">
          <el-select v-model="playerForm.clubId" placeholder="选择俱乐部" style="width:100%">
            <el-option v-for="c in allClubs" :key="c.clubId" :label="c.shortName || c.name" :value="c.clubId" />
          </el-select>
        </el-form-item>
        <el-form-item label="位置">
          <el-select v-model="playerForm.position" style="width:100%">
            <el-option label="门将" value="GK" />
            <el-option label="后卫" value="DEF" />
            <el-option label="中场" value="MID" />
            <el-option label="前锋" value="FWD" />
          </el-select>
        </el-form-item>
        <el-form-item label="号码">
          <el-input-number v-model="playerForm.jerseyNumber" :min="0" :max="99" />
        </el-form-item>
        <el-form-item label="国籍">
          <el-input v-model="playerForm.nationality" />
        </el-form-item>
        <el-form-item label="身高(cm)">
          <el-input-number v-model="playerForm.heightCm" :min="0" />
        </el-form-item>
        <el-form-item label="体重(kg)">
          <el-input-number v-model="playerForm.weightKg" :min="0" />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="playerForm.status" style="width:100%">
            <el-option label="活跃" value="ACTIVE" />
            <el-option label="受伤" value="INJURED" />
            <el-option label="自由身" value="FREE" />
            <el-option label="退役" value="RETIRED" />
          </el-select>
        </el-form-item>
        <el-form-item label="身价">
          <el-input-number v-model="playerForm.marketValue" :min="0" :step="1000000" style="width:100%" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="playerDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSavePlayer">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, watch, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { adminApi, clubApi, playerApi } from '@/api'
import ImageUpload from '@/components/ImageUpload.vue'

const activeTab = ref('stats')
const pageSize = ref(20)

const stats = ref<any>({})

const users = ref<any[]>([])
const userPage = ref(1)
const userTotal = ref(0)
const userFilterRole = ref('')
const userKeyword = ref('')

const matches = ref<any[]>([])
const matchPage = ref(1)
const matchTotal = ref(0)
const matchFilterLeague = ref('')
const matchFilterStatus = ref('')

const transfers = ref<any[]>([])
const transferPage = ref(1)
const transferTotal = ref(0)
const transferFilterType = ref('')

const clubs = ref<any[]>([])
const clubPage = ref(1)
const clubTotal = ref(0)

const players = ref<any[]>([])
const playerPage = ref(1)
const playerTotal = ref(0)
const playerFilterClub = ref<any>('')
const playerKeyword = ref('')

const allClubs = ref<any[]>([])
const allPlayers = ref<any[]>([])

const matchDialogVisible = ref(false)
const matchForm = ref<any>({})

const transferDialogVisible = ref(false)
const transferForm = ref<any>({})

const clubDialogVisible = ref(false)
const clubForm = ref<any>({})

const playerDialogVisible = ref(false)
const playerForm = ref<any>({})

const matchStatusMap: Record<string, string> = { PENDING: '未开始', IN_PROGRESS: '进行中', FINISHED: '已结束' }
const transferTypeMap: Record<string, string> = { IN: '转入', OUT: '转出', LOAN: '租借', FREE: '自由身' }
const playerStatusMap: Record<string, string> = { ACTIVE: '活跃', INJURED: '受伤', FREE: '自由身', RETIRED: '退役' }

function matchStatusType(status: string) {
  if (status === 'FINISHED') return 'success'
  if (status === 'IN_PROGRESS') return 'warning'
  return 'info'
}

function getClubName(clubId: number) {
  const club = allClubs.value.find(c => c.clubId === clubId)
  return club ? (club.shortName || club.name) : `#${clubId}`
}

function getPlayerName(playerId: number) {
  const p = allPlayers.value.find(p => p.playerId === playerId)
  return p ? (p.nameCn || p.name) : `#${playerId}`
}

function formatTime(time: string) {
  if (!time) return ''
  return new Date(time).toLocaleString('zh-CN', { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit', hour12: false })
}

watch(activeTab, (tab) => {
  if (tab === 'stats') fetchStats()
  if (tab === 'users' && users.value.length === 0) fetchUsers()
  if (tab === 'matches' && matches.value.length === 0) fetchMatches()
  if (tab === 'transfers' && transfers.value.length === 0) fetchTransfers()
  if (tab === 'clubs' && clubs.value.length === 0) fetchClubs()
  if (tab === 'players' && players.value.length === 0) fetchPlayers()
})

onMounted(() => {
  fetchStats()
  fetchAllClubs()
  fetchAllPlayers()
})

async function fetchAllClubs() {
  try {
    const res = await clubApi.list({ page: 1, pageSize: 200 })
    allClubs.value = res.data.data?.records || []
  } catch (e) { console.error(e) }
}

async function fetchAllPlayers() {
  try {
    const res = await playerApi.list({ page: 1, pageSize: 500 })
    allPlayers.value = res.data.data?.records || []
  } catch (e) { console.error(e) }
}

async function fetchStats() {
  try {
    const res = await adminApi.getStats()
    stats.value = res.data.data
  } catch (e) { console.error(e) }
}

async function fetchUsers() {
  try {
    const res = await adminApi.listUsers({ page: userPage.value, pageSize: pageSize.value, role: userFilterRole.value || undefined, keyword: userKeyword.value || undefined })
    users.value = res.data.data?.records || []
    userTotal.value = res.data.data?.total || 0
  } catch (e) { console.error(e) }
}

async function fetchMatches() {
  try {
    const res = await adminApi.listMatches({ page: matchPage.value, pageSize: pageSize.value, league: matchFilterLeague.value || undefined, status: matchFilterStatus.value || undefined })
    matches.value = res.data.data?.records || []
    matchTotal.value = res.data.data?.total || 0
  } catch (e) { console.error(e) }
}

async function fetchTransfers() {
  try {
    const res = await adminApi.listTransfers({ page: transferPage.value, pageSize: pageSize.value, transferType: transferFilterType.value || undefined })
    transfers.value = res.data.data?.records || []
    transferTotal.value = res.data.data?.total || 0
  } catch (e) { console.error(e) }
}

async function fetchClubs() {
  try {
    const res = await adminApi.listClubs({ page: clubPage.value, pageSize: pageSize.value })
    clubs.value = res.data.data?.records || []
    clubTotal.value = res.data.data?.total || 0
  } catch (e) { console.error(e) }
}

async function fetchPlayers() {
  try {
    const res = await adminApi.listPlayers({ page: playerPage.value, pageSize: pageSize.value, clubId: playerFilterClub.value || undefined, keyword: playerKeyword.value || undefined })
    players.value = res.data.data?.records || []
    playerTotal.value = res.data.data?.total || 0
  } catch (e) { console.error(e) }
}

async function toggleUserStatus(userId: number, status: string) {
  try {
    await adminApi.updateStatus(userId, status)
    ElMessage.success(status === 'ACTIVE' ? '用户已启用' : '用户已禁用')
    fetchUsers()
  } catch (e: any) { ElMessage.error(e.response?.data?.message || '操作失败') }
}

async function handleRoleChange(userId: number, role: string) {
  try {
    await adminApi.updateRole(userId, role)
    ElMessage.success('角色已更新')
    fetchUsers()
  } catch (e: any) { ElMessage.error(e.response?.data?.message || '操作失败') }
}

async function handleAssignClub(userId: number, managedClubId: number) {
  try {
    await adminApi.assignClub(userId, managedClubId)
    ElMessage.success('俱乐部已分配')
  } catch (e: any) { ElMessage.error(e.response?.data?.message || '操作失败') }
}

function openMatchDialog(row?: any) {
  if (row) {
    matchForm.value = { ...row }
  } else {
    matchForm.value = { matchId: '', homeClubId: null, awayClubId: null, matchTime: null, league: '', season: '2024-2025', round: '', venue: '', referee: '', status: 'PENDING', homeScore: null, awayScore: null }
  }
  matchDialogVisible.value = true
}

async function handleSaveMatch() {
  try {
    if (matchForm.value.matchId && matches.value.some(m => m.matchId === matchForm.value.matchId)) {
      await adminApi.updateMatch(matchForm.value.matchId, matchForm.value)
    } else {
      await adminApi.createMatch(matchForm.value)
    }
    ElMessage.success('比赛已保存')
    matchDialogVisible.value = false
    fetchMatches()
  } catch (e: any) { ElMessage.error(e.response?.data?.message || '保存失败') }
}

async function handleDeleteMatch(matchId: string) {
  try {
    await ElMessageBox.confirm('确定删除该比赛？', '确认', { type: 'warning' })
    await adminApi.deleteMatch(matchId)
    ElMessage.success('比赛已删除')
    fetchMatches()
  } catch { }
}

function openTransferDialog() {
  transferForm.value = { playerId: null, newClubId: null, transferType: 'OUT', transferFee: null, season: '2024-2025', notes: '' }
  transferDialogVisible.value = true
}

function onTransferPlayerChange(playerId: number) {
  const p = allPlayers.value.find(p => p.playerId === playerId)
  if (p && p.clubId) {
    transferForm.value.transferType = 'OUT'
  } else {
    transferForm.value.transferType = 'IN'
  }
}

async function handleSaveTransfer() {
  try {
    await adminApi.createTransfer(transferForm.value)
    ElMessage.success('转会已完成')
    transferDialogVisible.value = false
    fetchTransfers()
    fetchAllPlayers()
  } catch (e: any) { ElMessage.error(e.response?.data?.message || '转会失败') }
}

async function handleDeleteTransfer(logId: number) {
  try {
    await ElMessageBox.confirm('确定删除该转会记录？', '确认', { type: 'warning' })
    await adminApi.deleteTransfer(logId)
    ElMessage.success('记录已删除')
    fetchTransfers()
  } catch { }
}

function openClubDialog(row?: any) {
  if (row) {
    clubForm.value = { ...row }
  } else {
    clubForm.value = { name: '', shortName: '', league: '', city: '', country: '', stadium: '', stadiumCapacity: null, description: '', logoUrl: '' }
  }
  clubDialogVisible.value = true
}

async function handleSaveClub() {
  try {
    if (clubForm.value.clubId) {
      await adminApi.updateClub(clubForm.value.clubId, clubForm.value)
    } else {
      await adminApi.createClub(clubForm.value)
    }
    ElMessage.success('俱乐部已保存')
    clubDialogVisible.value = false
    fetchClubs()
    fetchAllClubs()
  } catch (e: any) { ElMessage.error(e.response?.data?.message || '保存失败') }
}

async function handleDeleteClub(clubId: number) {
  try {
    await ElMessageBox.confirm('确定删除该俱乐部？', '确认', { type: 'warning' })
    await adminApi.deleteClub(clubId)
    ElMessage.success('俱乐部已删除')
    fetchClubs()
    fetchAllClubs()
  } catch { }
}

function openPlayerDialog(row?: any) {
  if (row) {
    playerForm.value = { ...row }
  } else {
    playerForm.value = { name: '', nameCn: '', clubId: null, position: 'MID', jerseyNumber: null, nationality: '', heightCm: null, weightKg: null, status: 'ACTIVE', marketValue: null, avatarUrl: '' }
  }
  playerDialogVisible.value = true
}

async function handleSavePlayer() {
  try {
    if (playerForm.value.playerId) {
      await adminApi.updatePlayer(playerForm.value.playerId, playerForm.value)
    } else {
      await adminApi.createPlayer(playerForm.value)
    }
    ElMessage.success('球员已保存')
    playerDialogVisible.value = false
    fetchPlayers()
    fetchAllPlayers()
  } catch (e: any) { ElMessage.error(e.response?.data?.message || '保存失败') }
}

async function handleDeletePlayer(playerId: number) {
  try {
    await ElMessageBox.confirm('确定删除该球员？', '确认', { type: 'warning' })
    await adminApi.deletePlayer(playerId)
    ElMessage.success('球员已删除')
    fetchPlayers()
    fetchAllPlayers()
  } catch { }
}
</script>

<style scoped lang="scss">
.admin-tabs {
  background: #ffffff;
  border-radius: 10px;
  padding: 20px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);
}

.toolbar {
  display: flex;
  gap: 10px;
  margin-bottom: 16px;
  flex-wrap: wrap;
  align-items: center;
}

.pagination-wrapper {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 14px;

  @media (max-width: 800px) {
    grid-template-columns: repeat(2, 1fr);
  }
}

.stat-card {
  text-align: center;
  padding: 24px;
  background: #f5f5f5;
  border-radius: 10px;

  .stat-value {
    display: block;
    font-size: 32px;
    font-weight: 700;
    color: #1a56db;
  }

  .stat-label {
    font-size: 14px;
    color: #737373;
    margin-top: 4px;
  }
}
</style>
