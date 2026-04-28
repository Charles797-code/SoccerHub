<template>
  <div class="page-container">
    <div class="page-header">
      <el-button text @click="router.push('/matches')">
        <el-icon><ArrowLeft /></el-icon> 返回赛程
      </el-button>
    </div>

    <div v-if="match" class="match-detail-card">
      <div class="match-league-bar">
        <span class="league-name">{{ getLeagueNameCN(match.league) }}</span>
        <span class="match-round">{{ match.round }}</span>
        <span class="match-season">{{ match.season }}</span>
      </div>

      <div class="match-teams-row">
        <div class="team-col" @click="selectTeam(match.homeClubId)" :class="{ active: selectedClubId === match.homeClubId }">
          <div class="team-logo-big">
            <img v-if="getClubLogo(match.homeClubId)" :src="getImageUrl(getClubLogo(match.homeClubId))" alt="logo" />
            <span v-else>{{ getClubName(match.homeClubId)?.charAt(0) }}</span>
          </div>
          <div class="team-name-big">{{ getClubName(match.homeClubId) }}</div>
        </div>
        <div class="match-center-col">
          <div class="score-display">
            <span v-if="match.homeScore !== null" class="score-num">{{ match.homeScore }}</span>
            <span v-else class="vs-label">VS</span>
            <span v-if="match.homeScore !== null" class="score-sep">-</span>
            <span v-if="match.awayScore !== null" class="score-num">{{ match.awayScore }}</span>
          </div>
          <div class="match-meta">
            <span class="match-status" :class="match.status?.toLowerCase()">{{ getStatusLabel(match.status) }}</span>
          </div>
          <div class="match-time-info">{{ formatTime(match.matchTime) }}</div>
          <div v-if="match.venue" class="match-venue">🏟 {{ match.venue }}</div>
        </div>
        <div class="team-col" @click="selectTeam(match.awayClubId)" :class="{ active: selectedClubId === match.awayClubId }">
          <div class="team-logo-big">
            <img v-if="getClubLogo(match.awayClubId)" :src="getImageUrl(getClubLogo(match.awayClubId))" alt="logo" />
            <span v-else>{{ getClubName(match.awayClubId)?.charAt(0) }}</span>
          </div>
          <div class="team-name-big">{{ getClubName(match.awayClubId) }}</div>
        </div>
      </div>
    </div>

    <div v-else class="loading-state">
      <el-skeleton :rows="5" animated />
    </div>

    <div v-if="match && matchEvents.length > 0" class="match-events-section">
      <div class="section-header">
        <h2>⚽ 比赛事件</h2>
      </div>
      <div class="events-timeline">
        <div v-for="event in matchEvents" :key="event.eventId" class="event-item" :class="event.eventType.toLowerCase()">
          <div class="event-minute">{{ event.matchMinute }}'</div>
          <div class="event-icon">
            <span v-if="event.eventType === 'GOAL'">⚽</span>
            <span v-else-if="event.eventType === 'PENALTY'">🔢</span>
            <span v-else-if="event.eventType === 'OWN_GOAL'">⚽🔴</span>
            <span v-else-if="event.eventType === 'YELLOW_CARD'">🟨</span>
            <span v-else-if="event.eventType === 'RED_CARD'">🟥</span>
            <span v-else-if="event.eventType === 'SUBSTITUTION'">🔄</span>
            <span v-else>•</span>
          </div>
          <div class="event-info">
            <span class="event-player">{{ getPlayerName(event.playerId) }}</span>
            <span v-if="event.eventType === 'GOAL' && event.assistPlayerId" class="event-assist">助攻: {{ getPlayerName(event.assistPlayerId) }}</span>
            <span class="event-type-label">{{ getEventTypeLabel(event.eventType) }}</span>
          </div>
          <div class="event-team">{{ getClubName(event.clubId) }}</div>
        </div>
      </div>
    </div>

    <div v-if="match && canPredict" class="prediction-section">
      <div class="section-header">
        <h2>🎯 球迷竞猜</h2>
        <span class="points-display">我的积分: {{ userPoints }}</span>
      </div>

      <div v-if="myPrediction" class="my-prediction-card">
        <div class="prediction-info">
          <div class="prediction-result">
            <span class="prediction-label">我的预测:</span>
            <span class="prediction-value">{{ getResultLabel(myPrediction.predictedResult) }}</span>
            <span v-if="myPrediction.predictedHomeScore !== null" class="prediction-score">
              ({{ myPrediction.predictedHomeScore }} - {{ myPrediction.predictedAwayScore }})
            </span>
          </div>
          <div class="prediction-status" :class="myPrediction.status?.toLowerCase()">
            {{ myPrediction.status === 'PENDING' ? '待开奖' : myPrediction.status === 'SETTLED' ? `已结算 (+${myPrediction.pointsEarned}分)` : '' }}
          </div>
        </div>
      </div>

      <div v-else class="prediction-form">
        <div class="prediction-teams">
          <span class="team-name">{{ getClubName(match.homeClubId) }}</span>
          <span class="vs">VS</span>
          <span class="team-name">{{ getClubName(match.awayClubId) }}</span>
        </div>

        <div class="prediction-inputs">
          <el-radio-group v-model="predictionResult" class="result-select">
            <el-radio value="HOME_WIN">{{ getClubName(match.homeClubId) }} 胜</el-radio>
            <el-radio value="DRAW">平局</el-radio>
            <el-radio value="AWAY_WIN">{{ getClubName(match.awayClubId) }} 胜</el-radio>
          </el-radio-group>
        </div>

        <el-button
          type="primary"
          :loading="submittingPrediction"
          :disabled="!predictionResult"
          @click="submitPrediction"
        >提交预测</el-button>
      </div>
    </div>

    <div v-if="match" class="player-rating-section">
      <div class="section-header">
        <h2>⭐ 球员评分</h2>
        <div class="team-toggle">
          <el-radio-group v-model="selectedClubId" size="small">
            <el-radio-button :value="match.homeClubId">{{ getClubName(match.homeClubId) }}</el-radio-button>
            <el-radio-button :value="match.awayClubId">{{ getClubName(match.awayClubId) }}</el-radio-button>
          </el-radio-group>
        </div>
      </div>

      <div v-if="playerRatings.length > 0" class="players-grid">
        <div v-for="p in playerRatings" :key="p.playerId" class="player-rating-card">
          <div class="player-info">
            <div class="player-avatar">
              <img v-if="p.avatarUrl" :src="getImageUrl(p.avatarUrl)" alt="头像" />
              <span v-else>{{ (p.playerNameCn || p.playerName)?.charAt(0) }}</span>
            </div>
            <div class="player-detail">
              <div class="player-name">{{ p.playerNameCn || p.playerName }}</div>
              <div class="player-meta-row">
                <span class="position-tag" :class="p.position?.toLowerCase()">{{ positionMap[p.position] || p.position }}</span>
                <span v-if="p.jerseyNumber" class="jersey-num">#{{ p.jerseyNumber }}</span>
              </div>
            </div>
          </div>
          <div class="player-score-area">
            <div class="avg-score" :class="getScoreClass(p.avgScore)">
              {{ p.avgScore && p.avgScore > 0 ? p.avgScore.toFixed(1) : '-' }}
            </div>
            <div class="rating-count" v-if="p.totalRatings > 0">{{ p.totalRatings }}人评分</div>
          </div>
          <div class="player-rate-action">
            <div v-if="p.myScore" class="my-score-badge">我的评分: {{ p.myScore }}</div>
            <el-rate
              v-model="p._tempScore"
              :max="10"
              size="small"
              @change="(val: number) => ratePlayer(p.playerId, val)"
            />
          </div>
        </div>
      </div>
      <div v-else class="empty-players">暂无球员数据</div>
    </div>

    <div class="comment-section">
      <div class="section-header">
        <h2>💬 比赛评论</h2>
        <span class="comment-count">{{ total }} 条评论</span>
      </div>

      <div class="comment-input-area">
        <el-input
          v-model="newComment"
          type="textarea"
          :rows="2"
          placeholder="发表你对这场比赛的看法..."
          maxlength="1000"
          show-word-limit
          :disabled="submitting"
        />
        <el-button
          type="primary"
          :loading="submitting"
          :disabled="!newComment.trim()"
          @click="submitComment"
          style="margin-top: 10px; align-self: flex-end;"
        >发表评论</el-button>
      </div>

      <div class="comments-list">
        <div v-for="comment in comments" :key="comment.commentId" class="comment-item">
          <div class="comment-avatar">{{ getUserName(comment.userId)?.charAt(0) || 'U' }}</div>
          <div class="comment-body">
            <div class="comment-header">
              <span class="comment-username">{{ getUserName(comment.userId) }}</span>
              <span class="comment-time">{{ formatTime(comment.createdAt) }}</span>
              <el-button
                v-if="canDelete(comment)"
                type="danger"
                text
                size="small"
                @click="handleDelete(comment.commentId)"
              >删除</el-button>
            </div>
            <div class="comment-content">{{ comment.content }}</div>
          </div>
        </div>

        <div v-if="comments.length === 0" class="empty-comments">
          暂无评论，快来发表第一条评论吧！
        </div>
      </div>

      <div v-if="total > comments.length" class="load-more">
        <el-button text @click="loadMore">加载更多评论</el-button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ArrowLeft } from '@element-plus/icons-vue'
import { matchApi, clubApi, predictionApi } from '@/api'
import api from '@/api'
import { useAuthStore } from '@/stores/auth'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const matchId = route.params.id as string
const match = ref<any>(null)
const comments = ref<any[]>([])
const newComment = ref('')
const submitting = ref(false)
const currentPage = ref(1)
const total = ref(0)
const pageSize = 20

const selectedClubId = ref<number>(0)
const playerRatings = ref<any[]>([])
const matchEvents = ref<any[]>([])
const playerNameMap = ref<Record<number, string>>({})
const userPoints = ref<number>(0)
const myPrediction = ref<any>(null)
const predictionDialogVisible = ref(false)
const predictionResult = ref('')
const submittingPrediction = ref(false)

const clubNameMap = ref<Record<number, string>>({})
const clubLogoMap = ref<Record<number, string>>({})
const userNameMap = ref<Record<number, string>>({})

const leagueNameMap: Record<string, string> = {
  'La Liga': '西甲',
  'Premier League': '英超',
  'Bundesliga': '德甲',
  'Serie A': '意甲',
  'Ligue 1': '法甲'
}

const statusLabelMap: Record<string, string> = {
  SCHEDULED: '未开始',
  PENDING: '未开始',
  IN_PROGRESS: '进行中',
  LIVE: '直播中',
  FINISHED: '已结束'
}

const positionMap: Record<string, string> = {
  FW: '前锋', MF: '中场', DF: '后卫', GK: '门将'
}

const eventTypeLabelMap: Record<string, string> = {
  GOAL: '进球',
  PENALTY: '点球',
  OWN_GOAL: '乌龙球',
  ASSIST: '助攻',
  YELLOW_CARD: '黄牌',
  RED_CARD: '红牌',
  SUBSTITUTION: '换人'
}

function getEventTypeLabel(type: string) { return eventTypeLabelMap[type] || type }

function getLeagueNameCN(league: string) { return leagueNameMap[league] || league }
function getStatusLabel(status: string) { return statusLabelMap[status] || status }
function getClubName(clubId: number) { return clubNameMap.value[clubId] || `球队${clubId}` }
function getClubLogo(clubId: number) { return clubLogoMap.value[clubId] || '' }
function getUserName(userId: number) { return userNameMap.value[userId] || `用户${userId}` }
function getPlayerName(playerId: number) { return playerNameMap.value[playerId] || `球员${playerId}` }

function getScoreClass(score: number) {
  if (!score || score === 0) return ''
  if (score >= 8) return 'score-high'
  if (score >= 6) return 'score-mid'
  return 'score-low'
}

function canPredict() {
  if (!match.value) return false
  return authStore.isLoggedIn && (match.value.status === 'PENDING' || match.value.status === 'SCHEDULED')
}

function getResultLabel(result: string) {
  const map: Record<string, string> = {
    HOME_WIN: '主队胜',
    AWAY_WIN: '客队胜',
    DRAW: '平局'
  }
  return map[result] || result
}

function getImageUrl(path: string) {
  if (!path) return ''
  if (path.startsWith('http://') || path.startsWith('https://')) return path
  if (path.startsWith('/uploads/')) return path
  return '/uploads/' + path.replace(/^\//, '')
}

function formatTime(time: string) {
  if (!time) return ''
  return new Date(time).toLocaleString('zh-CN', {
    month: 'short', day: 'numeric',
    hour: '2-digit', minute: '2-digit', hour12: false
  })
}

function canDelete(comment: any) {
  if (!authStore.user) return false
  return comment.userId === authStore.user.userId || authStore.isSuperAdmin
}

function selectTeam(clubId: number) {
  selectedClubId.value = clubId
}

watch(selectedClubId, () => {
  if (selectedClubId.value) fetchPlayerRatings()
})

onMounted(async () => {
  try {
    const clubsRes = await clubApi.list({ page: 1, pageSize: 100 })
    const allClubs = clubsRes.data.data?.records || []
    allClubs.forEach((c: any) => {
      clubNameMap.value[c.clubId] = c.shortName || c.name
      clubLogoMap.value[c.clubId] = c.logoUrl || ''
    })
  } catch (e) { console.error(e) }

  try {
    const res = await matchApi.getById(matchId)
    match.value = res.data.data
    if (match.value) {
      selectedClubId.value = match.value.homeClubId
    }
  } catch (e) { console.error(e) }

  fetchComments()
  fetchMatchEvents()
  if (authStore.isLoggedIn) {
    fetchUserPoints()
    fetchMyPrediction()
  }
})

async function fetchMatchEvents() {
  try {
    const res = await matchApi.getEvents(matchId)
    matchEvents.value = res.data.data || []
    const playerIds = new Set<number>()
    matchEvents.value.forEach((e: any) => {
      if (e.playerId) playerIds.add(e.playerId)
      if (e.assistPlayerId) playerIds.add(e.assistPlayerId)
    })
    if (playerIds.size > 0) {
      await loadPlayerNames(Array.from(playerIds))
    }
  } catch (e) { console.error(e) }
}

async function loadPlayerNames(playerIds: number[]) {
  for (const id of playerIds) {
    if (!playerNameMap.value[id]) {
      try {
        const res = await api.get(`/players/${id}`)
        const player = res.data.data
        playerNameMap.value[id] = player?.nameCn || player?.name || `球员${id}`
      } catch {
        playerNameMap.value[id] = `球员${id}`
      }
    }
  }
}

async function fetchUserPoints() {
  if (!authStore.user) return
  try {
    const res = await predictionApi.getUserPoints(authStore.user.userId)
    userPoints.value = res.data.data?.points || 0
  } catch (e) { console.error(e) }
}

async function fetchMyPrediction() {
  if (!authStore.user || !match.value) return
  try {
    const res = await predictionApi.getForMatch(matchId, authStore.user.userId)
    myPrediction.value = res.data.data
  } catch (e) { console.error(e) }
}

async function submitPrediction() {
  if (!authStore.user || !predictionResult.value) return
  submittingPrediction.value = true
  try {
    await predictionApi.make({
      userId: authStore.user.userId,
      matchId: matchId,
      predictedResult: predictionResult.value
    })
    await fetchMyPrediction()
    await fetchUserPoints()
    predictionResult.value = ''
  } catch (e: any) {
    console.error(e)
  } finally {
    submittingPrediction.value = false
  }
}

async function fetchPlayerRatings() {
  if (!selectedClubId.value) return
  try {
    const res = await api.get(`/matches/${matchId}/player-ratings`, {
      params: { clubId: selectedClubId.value }
    })
    playerRatings.value = (res.data.data || []).map((p: any) => ({
      ...p,
      _tempScore: p.myScore || 0
    }))
  } catch (e) { console.error(e) }
}

async function ratePlayer(playerId: number, score: number) {
  if (!score || score < 1) return
  try {
    const res = await api.post(`/matches/${matchId}/player-ratings`, {
      playerId, score
    })
    const updated = res.data.data
    const idx = playerRatings.value.findIndex(p => p.playerId === playerId)
    if (idx !== -1) {
      playerRatings.value[idx] = {
        ...playerRatings.value[idx],
        avgScore: updated.avgScore,
        totalRatings: updated.totalRatings,
        myScore: updated.myScore,
        _tempScore: updated.myScore
      }
    }
  } catch (e: any) {
    console.error(e)
  }
}

async function fetchComments() {
  try {
    const res = await api.get(`/matches/${matchId}/comments`, {
      params: { page: currentPage.value, pageSize }
    })
    const data = res.data.data
    const records = data.records || []
    comments.value = currentPage.value === 1 ? records : [...comments.value, ...records]
    total.value = data.total || 0
    loadUserNames(records)
  } catch (e) { console.error(e) }
}

async function loadUserNames(records: any[]) {
  for (const r of records) {
    if (!userNameMap.value[r.userId]) {
      try {
        const res = await api.get(`/auth/user/${r.userId}`)
        userNameMap.value[r.userId] = res.data.data?.nickname || res.data.data?.username || `用户${r.userId}`
      } catch {
        userNameMap.value[r.userId] = `用户${r.userId}`
      }
    }
  }
}

async function submitComment() {
  if (!newComment.value.trim() || submitting.value) return
  submitting.value = true
  try {
    await api.post(`/matches/${matchId}/comments`, { content: newComment.value.trim() })
    newComment.value = ''
    currentPage.value = 1
    await fetchComments()
  } catch (e: any) {
    console.error(e)
  } finally {
    submitting.value = false
  }
}

async function handleDelete(commentId: number) {
  try {
    await api.delete(`/matches/${matchId}/comments/${commentId}`)
    comments.value = comments.value.filter(c => c.commentId !== commentId)
    total.value--
  } catch (e) { console.error(e) }
}

function loadMore() {
  currentPage.value++
  fetchComments()
}
</script>

<style scoped lang="scss">
@use '@/styles/tokens' as *;

.prediction-section {
  background: $surface-card;
  border: 1px solid $border-subtle;
  border-radius: $radius-xl;
  padding: $space-5;
  margin-top: $space-5;
}

.points-display {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: $space-1 $space-3;
  border-radius: $radius-full;
  font-size: $font-size-sm;
  font-weight: 500;
}

.my-prediction-card {
  background: $surface-elevated;
  border-radius: $radius-lg;
  padding: $space-4;
}

.prediction-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.prediction-result {
  display: flex;
  align-items: center;
  gap: $space-2;
}

.prediction-label {
  color: $text-muted;
  font-size: $font-size-sm;
}

.prediction-value {
  font-weight: 600;
  color: $text-primary;
}

.prediction-score {
  color: $text-secondary;
  font-size: $font-size-sm;
}

.prediction-status {
  font-size: $font-size-sm;
  font-weight: 500;

  &.pending { color: #f59e0b; }
  &.settled { color: #10b981; }
}

.prediction-form {
  display: flex;
  flex-direction: column;
  gap: $space-4;
}

.prediction-teams {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: $space-3;
  font-weight: 500;
}

.prediction-teams .vs {
  color: $text-muted;
  font-size: $font-size-sm;
}

.prediction-inputs {
  display: flex;
  flex-direction: column;
  gap: $space-3;
}

.result-select {
  display: flex;
  justify-content: center;
  gap: $space-4;
}

.score-inputs {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: $space-3;
}

.score-sep {
  font-size: 18px;
  font-weight: bold;
  color: $text-secondary;
}

.match-events-section {
  background: $surface-card;
  border: 1px solid $border-subtle;
  border-radius: $radius-xl;
  padding: $space-5;
  margin-top: $space-5;
}

.events-timeline {
  display: flex;
  flex-direction: column;
  gap: $space-2;
}

.event-item {
  display: flex;
  align-items: center;
  gap: $space-3;
  padding: $space-2 $space-3;
  border-radius: $radius-md;
  background: $surface-elevated;

  &.goal { border-left: 3px solid #10b981; }
  &.penalty { border-left: 3px solid #f59e0b; }
  &.own_goal { border-left: 3px solid #ef4444; }
  &.yellow_card { border-left: 3px solid #eab308; }
  &.red_card { border-left: 3px solid #ef4444; }
  &.substitution { border-left: 3px solid #6366f1; }
}

.event-minute {
  font-weight: bold;
  color: $text-secondary;
  min-width: 40px;
  font-size: $font-size-sm;
}

.event-icon {
  font-size: 18px;
}

.event-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.event-player {
  font-weight: 500;
  color: $text-primary;
}

.event-assist {
  font-size: $font-size-xs;
  color: $text-muted;
}

.event-type-label {
  font-size: $font-size-xs;
  color: $text-muted;
}

.event-team {
  font-size: $font-size-sm;
  color: $text-secondary;
}

.page-header {
  margin-bottom: $space-5;
}

.loading-state {
  padding: $space-10;
  background: $surface-card;
  border: 1px solid $border-subtle;
  border-radius: $radius-xl;
}

.empty-players {
  text-align: center;
  padding: $space-8;
  color: $text-muted;
  font-size: $font-size-base;
}

.empty-comments {
  text-align: center;
  padding: $space-8;
  color: $text-muted;
  font-size: $font-size-base;
}

.load-more {
  text-align: center;
  margin-top: $space-4;
  padding-top: $space-3;
  border-top: 1px solid $border-subtle;
}
</style>
