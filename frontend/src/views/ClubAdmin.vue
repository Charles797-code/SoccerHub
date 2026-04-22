<template>
  <div class="page-container">
    <div class="page-header">
      <h1>俱乐部管理后台</h1>
    </div>

    <div class="admin-tabs">
      <el-tabs v-model="activeTab" type="border-card">
        <el-tab-pane label="俱乐部信息" name="club">
          <div v-if="club" class="club-info-section">
            <el-descriptions :column="2" border>
              <el-descriptions-item label="俱乐部名称">{{ club.name }}</el-descriptions-item>
              <el-descriptions-item label="简称">{{ club.shortName || '-' }}</el-descriptions-item>
              <el-descriptions-item label="联赛">{{ club.league || '-' }}</el-descriptions-item>
              <el-descriptions-item label="城市">{{ club.city || '-' }}</el-descriptions-item>
              <el-descriptions-item label="国家">{{ club.country || '-' }}</el-descriptions-item>
              <el-descriptions-item label="主场">{{ club.stadium || '-' }}</el-descriptions-item>
              <el-descriptions-item label="球场容量">{{ club.stadiumCapacity ? club.stadiumCapacity.toLocaleString() : '-' }}</el-descriptions-item>
              <el-descriptions-item label="成立日期">{{ club.establishDate ? club.establishDate.substring(0, 10) : '-' }}</el-descriptions-item>
              <el-descriptions-item label="简介" :span="2">{{ club.description || '-' }}</el-descriptions-item>
            </el-descriptions>
            <div class="club-actions">
              <el-button type="primary" @click="openClubEditDialog">编辑俱乐部信息</el-button>
            </div>
          </div>
          <el-empty v-else description="暂无俱乐部信息" />
        </el-tab-pane>

        <el-tab-pane label="球员管理" name="players">
          <div class="toolbar">
            <el-select v-model="playerFilterPosition" placeholder="位置筛选" clearable style="width:120px" @change="fetchPlayers">
              <el-option label="门将" value="GK" />
              <el-option label="后卫" value="DEF" />
              <el-option label="中场" value="MID" />
              <el-option label="前锋" value="FWD" />
            </el-select>
            <el-select v-model="playerFilterStatus" placeholder="状态筛选" clearable style="width:120px" @change="fetchPlayers">
              <el-option label="活跃" value="ACTIVE" />
              <el-option label="受伤" value="INJURED" />
              <el-option label="自由身" value="FREE" />
              <el-option label="退役" value="RETIRED" />
            </el-select>
            <el-input v-model="playerKeyword" placeholder="搜索球员姓名" clearable style="width:180px" @keyup.enter="fetchPlayers" />
            <el-button type="primary" @click="fetchPlayers">搜索</el-button>
            <el-button type="success" @click="openPlayerDialog()">新增球员</el-button>
          </div>
          <el-table :data="players" stripe>
            <el-table-column prop="playerId" label="ID" width="70" />
            <el-table-column prop="nameCn" label="中文名" width="100" />
            <el-table-column prop="name" label="英文名" width="120" />
            <el-table-column prop="position" label="位置" width="70">
              <template #default="{ row }">{{ positionMap[row.position] || row.position }}</template>
            </el-table-column>
            <el-table-column prop="jerseyNumber" label="号码" width="60" />
            <el-table-column prop="nationality" label="国籍" width="80" />
            <el-table-column label="出生日期" width="100">
              <template #default="{ row }">{{ row.birthDate ? row.birthDate.substring(0, 10) : '-' }}</template>
            </el-table-column>
            <el-table-column prop="status" label="状态" width="80">
              <template #default="{ row }">
                <el-tag :type="playerStatusType(row.status)" size="small">{{ playerStatusMap[row.status] || row.status }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="avgScore" label="评分" width="70" />
            <el-table-column label="操作" width="200">
              <template #default="{ row }">
                <el-button size="small" @click="openPlayerDialog(row)">编辑</el-button>
                <el-button type="warning" size="small" @click="openTransferDialog(row)">转会</el-button>
                <el-button type="danger" size="small" @click="handleDeletePlayer(row.playerId)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
          <div class="pagination-wrapper">
            <el-pagination v-model:current-page="playerPage" :page-size="pageSize" :total="playerTotal" layout="prev, pager, next" @current-change="fetchPlayers" />
          </div>
        </el-tab-pane>

        <el-tab-pane label="教练组" name="coaches">
          <div class="toolbar">
            <el-select v-model="coachFilterRole" placeholder="职务筛选" clearable style="width:140px" @change="fetchCoaches">
              <el-option label="主教练" value="HEAD_COACH" />
              <el-option label="助理教练" value="ASSISTANT_COACH" />
              <el-option label="守门员教练" value="GOALKEEPER_COACH" />
              <el-option label="体能教练" value="FITNESS_COACH" />
              <el-option label="战术分析师" value="TACTICAL_ANALYST" />
              <el-option label="队医" value="TEAM_DOCTOR" />
            </el-select>
            <el-button type="success" @click="openCoachDialog()">新增教练</el-button>
          </div>
          <el-table :data="filteredCoaches" stripe>
            <el-table-column prop="coachId" label="ID" width="70" />
            <el-table-column prop="nameCn" label="中文名" width="100" />
            <el-table-column prop="name" label="英文名" width="130" />
            <el-table-column label="职务" width="120">
              <template #default="{ row }">
                <el-tag :type="coachRoleTagType(row.role)" size="small">{{ coachRoleMap[row.role] || row.role }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="nationality" label="国籍" width="80" />
            <el-table-column label="出生日期" width="100">
              <template #default="{ row }">{{ row.birthDate ? row.birthDate.substring(0, 10) : '-' }}</template>
            </el-table-column>
            <el-table-column prop="avgScore" label="评分" width="70" />
            <el-table-column label="操作" width="150">
              <template #default="{ row }">
                <el-button size="small" @click="openCoachDialog(row)">编辑</el-button>
                <el-button type="danger" size="small" @click="handleDeleteCoach(row.coachId)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
          <el-empty v-if="coaches.length === 0" description="暂无教练数据" />
        </el-tab-pane>
      </el-tabs>
    </div>

    <el-dialog v-model="clubEditDialogVisible" title="编辑俱乐部信息" width="600px">
      <el-form :model="clubForm" label-width="100px">
        <el-form-item label="俱乐部名称">
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
        <el-form-item label="球场容量">
          <el-input-number v-model="clubForm.stadiumCapacity" :min="0" style="width:100%" />
        </el-form-item>
        <el-form-item label="成立日期">
          <el-date-picker v-model="clubForm.establishDate" type="date" placeholder="选择日期" style="width:100%" />
        </el-form-item>
        <el-form-item label="简介">
          <el-input v-model="clubForm.description" type="textarea" :rows="4" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="clubEditDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSaveClub">保存</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="playerDialogVisible" :title="playerForm.playerId ? '编辑球员' : '新增球员'" width="550px">
      <el-form :model="playerForm" label-width="90px">
        <el-form-item label="英文名">
          <el-input v-model="playerForm.name" />
        </el-form-item>
        <el-form-item label="中文名">
          <el-input v-model="playerForm.nameCn" />
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
          <el-input-number v-model="playerForm.heightCm" :min="0" :max="250" />
        </el-form-item>
        <el-form-item label="体重(kg)">
          <el-input-number v-model="playerForm.weightKg" :min="0" :max="150" />
        </el-form-item>
        <el-form-item label="出生日期">
          <el-date-picker v-model="playerForm.birthDate" type="date" placeholder="选择日期" style="width:100%" />
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

    <el-dialog v-model="transferDialogVisible" title="球员转会" width="500px">
      <el-form :model="transferForm" label-width="90px">
        <el-form-item label="球员">
          <el-input :model-value="transferPlayerName" disabled />
        </el-form-item>
        <el-form-item label="目标俱乐部">
          <el-select v-model="transferForm.newClubId" placeholder="选择目标俱乐部" filterable style="width:100%">
            <el-option v-for="c in allClubs" :key="c.clubId" :label="c.shortName || c.name" :value="c.clubId" />
          </el-select>
        </el-form-item>
        <el-form-item label="转会类型">
          <el-select v-model="transferForm.transferType" style="width:100%">
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
        <el-button type="primary" @click="handleTransferPlayer">确认转会</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="coachDialogVisible" :title="coachForm.coachId ? '编辑教练' : '新增教练'" width="550px">
      <el-form :model="coachForm" label-width="90px">
        <el-form-item label="英文名">
          <el-input v-model="coachForm.name" />
        </el-form-item>
        <el-form-item label="中文名">
          <el-input v-model="coachForm.nameCn" />
        </el-form-item>
        <el-form-item label="职务">
          <el-select v-model="coachForm.role" style="width:100%">
            <el-option label="主教练" value="HEAD_COACH" />
            <el-option label="助理教练" value="ASSISTANT_COACH" />
            <el-option label="守门员教练" value="GOALKEEPER_COACH" />
            <el-option label="体能教练" value="FITNESS_COACH" />
            <el-option label="战术分析师" value="TACTICAL_ANALYST" />
            <el-option label="队医" value="TEAM_DOCTOR" />
          </el-select>
        </el-form-item>
        <el-form-item label="国籍">
          <el-input v-model="coachForm.nationality" />
        </el-form-item>
        <el-form-item label="出生日期">
          <el-date-picker v-model="coachForm.birthDate" type="date" placeholder="选择日期" style="width:100%" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="coachDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSaveCoach">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { clubAdminApi, clubApi } from '@/api'
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()
const activeTab = ref('club')
const pageSize = ref(20)

const club = ref<any>(null)
const clubEditDialogVisible = ref(false)
const clubForm = ref<any>({})

const players = ref<any[]>([])
const playerPage = ref(1)
const playerTotal = ref(0)
const playerFilterPosition = ref('')
const playerFilterStatus = ref('')
const playerKeyword = ref('')

const playerDialogVisible = ref(false)
const playerForm = ref<any>({})

const transferDialogVisible = ref(false)
const transferForm = ref<any>({})
const transferPlayerId = ref<number | null>(null)
const transferPlayerName = ref('')

const coaches = ref<any[]>([])
const coachFilterRole = ref('')
const coachDialogVisible = ref(false)
const coachForm = ref<any>({})
const allClubs = ref<any[]>([])

const positionMap: Record<string, string> = { GK: '门将', DEF: '后卫', MID: '中场', FWD: '前锋' }
const playerStatusMap: Record<string, string> = { ACTIVE: '活跃', INJURED: '受伤', FREE: '自由身', RETIRED: '退役' }
const coachRoleMap: Record<string, string> = {
  HEAD_COACH: '主教练',
  ASSISTANT_COACH: '助理教练',
  GOALKEEPER_COACH: '守门员教练',
  FITNESS_COACH: '体能教练',
  TACTICAL_ANALYST: '战术分析师',
  TEAM_DOCTOR: '队医'
}

function playerStatusType(status: string) {
  if (status === 'ACTIVE') return 'success'
  if (status === 'INJURED') return 'warning'
  if (status === 'RETIRED') return 'info'
  return 'danger'
}

const filteredCoaches = computed(() => {
  if (!coachFilterRole.value) return coaches.value
  return coaches.value.filter((c: any) => c.role === coachFilterRole.value)
})

function coachRoleTagType(role: string): 'danger' | 'warning' | 'success' | 'primary' | 'info' {
  if (role === 'HEAD_COACH') return 'danger'
  if (role === 'ASSISTANT_COACH') return 'warning'
  if (role === 'GOALKEEPER_COACH') return 'success'
  if (role === 'FITNESS_COACH') return 'primary'
  if (role === 'TACTICAL_ANALYST') return 'info'
  return 'info'
}

watch(activeTab, (tab) => {
  if (tab === 'club' && !club.value) fetchClub()
  if (tab === 'players' && players.value.length === 0) fetchPlayers()
  if (tab === 'coaches' && coaches.value.length === 0) fetchCoaches()
})

onMounted(() => {
  fetchClub()
  fetchAllClubs()
})

async function fetchAllClubs() {
  try {
    const res = await clubApi.list({ page: 1, pageSize: 200 })
    allClubs.value = res.data.data?.records || []
  } catch (e) { console.error(e) }
}

async function fetchClub() {
  try {
    const res = await clubAdminApi.getMyClub()
    club.value = res.data.data
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '获取俱乐部信息失败')
  }
}

function openClubEditDialog() {
  clubForm.value = { ...club.value }
  clubEditDialogVisible.value = true
}

async function handleSaveClub() {
  try {
    const res = await clubAdminApi.updateMyClub(clubForm.value)
    ElMessage.success('俱乐部信息已更新')
    clubEditDialogVisible.value = false
    club.value = res.data.data
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '更新失败')
  }
}

async function fetchPlayers() {
  try {
    const res = await clubAdminApi.listMyPlayers({
      page: playerPage.value,
      pageSize: pageSize.value,
      position: playerFilterPosition.value || undefined,
      status: playerFilterStatus.value || undefined,
      keyword: playerKeyword.value || undefined
    })
    players.value = res.data.data?.records || []
    playerTotal.value = res.data.data?.total || 0
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '获取球员列表失败')
  }
}

function openPlayerDialog(row?: any) {
  if (row) {
    playerForm.value = { ...row }
  } else {
    playerForm.value = {
      name: '', nameCn: '', position: 'MID', jerseyNumber: null,
      nationality: '', heightCm: null, weightKg: null, birthDate: null,
      status: 'ACTIVE', marketValue: null
    }
  }
  playerDialogVisible.value = true
}

async function handleSavePlayer() {
  try {
    if (playerForm.value.playerId) {
      await clubAdminApi.updateMyPlayer(playerForm.value.playerId, playerForm.value)
    } else {
      await clubAdminApi.createMyPlayer(playerForm.value)
    }
    ElMessage.success('球员信息已保存')
    playerDialogVisible.value = false
    fetchPlayers()
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '保存失败')
  }
}

async function handleDeletePlayer(playerId: number) {
  try {
    await ElMessageBox.confirm('确定删除该球员？此操作不可恢复', '确认删除', { type: 'warning' })
    await clubAdminApi.deleteMyPlayer(playerId)
    ElMessage.success('球员已删除')
    fetchPlayers()
  } catch { }
}

function openTransferDialog(row: any) {
  transferPlayerId.value = row.playerId
  transferPlayerName.value = row.nameCn || row.name
  transferForm.value = {
    newClubId: null,
    transferType: 'OUT',
    transferFee: null,
    season: '2024-2025',
    notes: ''
  }
  transferDialogVisible.value = true
}

async function handleTransferPlayer() {
  if (!transferForm.value.newClubId) {
    ElMessage.warning('请选择目标俱乐部')
    return
  }
  try {
    await clubAdminApi.transferMyPlayer(transferPlayerId.value!, transferForm.value)
    ElMessage.success('球员转会已完成')
    transferDialogVisible.value = false
    fetchPlayers()
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '转会失败')
  }
}

async function fetchCoaches() {
  try {
    const res = await clubAdminApi.listMyCoaches()
    coaches.value = res.data.data || []
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '获取教练列表失败')
  }
}

function openCoachDialog(row?: any) {
  if (row) {
    coachForm.value = { ...row }
  } else {
    coachForm.value = {
      name: '', nameCn: '', role: 'ASSISTANT_COACH',
      nationality: '', birthDate: null
    }
  }
  coachDialogVisible.value = true
}

async function handleSaveCoach() {
  try {
    if (coachForm.value.coachId) {
      await clubAdminApi.updateMyCoach(coachForm.value.coachId, coachForm.value)
    } else {
      await clubAdminApi.createMyCoach(coachForm.value)
    }
    ElMessage.success('教练信息已保存')
    coachDialogVisible.value = false
    fetchCoaches()
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '保存失败')
  }
}

async function handleDeleteCoach(coachId: number) {
  try {
    await ElMessageBox.confirm('确定删除该教练？此操作不可恢复', '确认删除', { type: 'warning' })
    await clubAdminApi.deleteMyCoach(coachId)
    ElMessage.success('教练已删除')
    fetchCoaches()
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

.club-info-section {
  .club-actions {
    margin-top: 20px;
    display: flex;
    gap: 10px;
  }
}
</style>
