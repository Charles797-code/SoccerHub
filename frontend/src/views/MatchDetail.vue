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
          <div class="team-logo-big">{{ getClubName(match.homeClubId)?.charAt(0) }}</div>
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
          <div class="team-logo-big">{{ getClubName(match.awayClubId)?.charAt(0) }}</div>
          <div class="team-name-big">{{ getClubName(match.awayClubId) }}</div>
        </div>
      </div>
    </div>

    <div v-else class="loading-state">
      <el-skeleton :rows="5" animated />
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
            <div class="player-avatar">{{ (p.playerNameCn || p.playerName)?.charAt(0) }}</div>
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
import { matchApi, clubApi } from '@/api'
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

const clubNameMap = ref<Record<number, string>>({})
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

function getLeagueNameCN(league: string) { return leagueNameMap[league] || league }
function getStatusLabel(status: string) { return statusLabelMap[status] || status }
function getClubName(clubId: number) { return clubNameMap.value[clubId] || `球队${clubId}` }
function getUserName(userId: number) { return userNameMap.value[userId] || `用户${userId}` }

function getScoreClass(score: number) {
  if (!score || score === 0) return ''
  if (score >= 8) return 'score-high'
  if (score >= 6) return 'score-mid'
  return 'score-low'
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
    allClubs.forEach((c: any) => { clubNameMap.value[c.clubId] = c.shortName || c.name })
  } catch (e) { console.error(e) }

  try {
    const res = await matchApi.getById(matchId)
    match.value = res.data.data
    if (match.value) {
      selectedClubId.value = match.value.homeClubId
    }
  } catch (e) { console.error(e) }

  fetchComments()
})

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
.match-detail-card {
  background: #ffffff;
  border-radius: 12px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
  overflow: hidden;
  margin-bottom: 20px;
}

.match-league-bar {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 24px;
  background: linear-gradient(135deg, #1a56db, #3b82f6);
  color: #fff;
  font-size: 13px;

  .league-name { font-weight: 600; font-size: 15px; }
  .match-round { opacity: 0.85; }
  .match-season { opacity: 0.7; margin-left: auto; }
}

.match-teams-row {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 32px 24px;
  gap: 40px;
}

.team-col {
  flex: 1;
  text-align: center;
  cursor: pointer;
  padding: 12px;
  border-radius: 12px;
  transition: all 0.2s;

  &:hover { background: #f0f4ff; }
  &.active { background: rgba(26, 86, 219, 0.08); }

  .team-logo-big {
    width: 72px;
    height: 72px;
    margin: 0 auto 12px;
    border-radius: 50%;
    background: #f0f4ff;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 30px;
    color: #1a56db;
  }

  .team-name-big {
    font-size: 18px;
    font-weight: 600;
    color: #262626;
  }
}

.match-center-col {
  text-align: center;
  min-width: 140px;

  .score-display {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;

    .score-num { font-size: 42px; font-weight: 800; color: #262626; }
    .score-sep { font-size: 32px; color: #a3a3a3; font-weight: 300; }
    .vs-label { font-size: 28px; color: #a3a3a3; font-weight: 600; }
  }

  .match-meta {
    margin-top: 8px;
    .match-status {
      font-size: 13px;
      padding: 3px 14px;
      border-radius: 12px;
      &.scheduled, &.pending { background: #f5f5f5; color: #a3a3a3; }
      &.in_progress, &.live { background: rgba(220, 38, 38, 0.08); color: #dc2626; }
      &.finished { background: rgba(22, 163, 74, 0.08); color: #16a34a; }
    }
  }

  .match-time-info { margin-top: 8px; font-size: 14px; color: #737373; }
  .match-venue { margin-top: 4px; font-size: 13px; color: #a3a3a3; }
}

.loading-state { padding: 40px; background: #fff; border-radius: 12px; }

.player-rating-section {
  background: #ffffff;
  border-radius: 12px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
  padding: 24px;
  margin-bottom: 20px;
}

.section-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 20px;

  h2 { font-size: 18px; font-weight: 600; color: #262626; margin: 0; }
  .comment-count { font-size: 13px; color: #a3a3a3; }
}

.players-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 12px;
}

.player-rating-card {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px;
  border-radius: 10px;
  border: 1px solid #f0f0f0;
  transition: all 0.2s;

  &:hover { border-color: #d0d7ff; box-shadow: 0 2px 8px rgba(26, 86, 219, 0.06); }
}

.player-info {
  display: flex;
  align-items: center;
  gap: 10px;
  flex: 1;
  min-width: 0;

  .player-avatar {
    width: 38px;
    height: 38px;
    border-radius: 50%;
    background: #f0f4ff;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 16px;
    color: #1a56db;
    flex-shrink: 0;
  }

  .player-detail { min-width: 0; }

  .player-name {
    font-size: 14px;
    font-weight: 600;
    color: #262626;
  }

  .player-meta-row {
    display: flex;
    align-items: center;
    gap: 6px;
    margin-top: 2px;

    .position-tag {
      font-size: 10px;
      padding: 1px 6px;
      border-radius: 6px;
      font-weight: 500;

      &.fw { background: rgba(220, 38, 38, 0.08); color: #dc2626; }
      &.mf { background: rgba(22, 163, 74, 0.08); color: #16a34a; }
      &.df { background: rgba(37, 99, 235, 0.08); color: #2563eb; }
      &.gk { background: rgba(234, 179, 8, 0.08); color: #ca8a04; }
    }

    .jersey-num { font-size: 11px; color: #a3a3a3; }
  }
}

.player-score-area {
  text-align: center;
  min-width: 50px;

  .avg-score {
    font-size: 24px;
    font-weight: 800;

    &.score-high { color: #16a34a; }
    &.score-mid { color: #ca8a04; }
    &.score-low { color: #dc2626; }
  }

  .rating-count { font-size: 10px; color: #a3a3a3; margin-top: 2px; }
}

.player-rate-action {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 4px;
  min-width: 120px;

  .my-score-badge {
    font-size: 11px;
    color: #1a56db;
    background: rgba(26, 86, 219, 0.06);
    padding: 1px 8px;
    border-radius: 8px;
  }

  :deep(.el-rate) {
    height: 20px;
    .el-rate__icon { font-size: 14px !important; margin-right: 2px !important; }
  }
}

.empty-players { text-align: center; padding: 32px; color: #a3a3a3; font-size: 14px; }

.comment-section {
  background: #ffffff;
  border-radius: 12px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
  padding: 24px;
}

.comment-input-area {
  display: flex;
  flex-direction: column;
  margin-bottom: 24px;
  padding-bottom: 20px;
  border-bottom: 1px solid #f0f0f0;
}

.comments-list { display: flex; flex-direction: column; gap: 16px; }

.comment-item {
  display: flex;
  gap: 12px;

  .comment-avatar {
    width: 38px; height: 38px; border-radius: 50%;
    background: rgba(26, 86, 219, 0.08);
    display: flex; align-items: center; justify-content: center;
    font-size: 15px; color: #1a56db; flex-shrink: 0;
  }

  .comment-body { flex: 1; min-width: 0; }

  .comment-header {
    display: flex; align-items: center; gap: 8px; margin-bottom: 4px;
    .comment-username { font-size: 13px; font-weight: 500; color: #262626; }
    .comment-time { font-size: 12px; color: #a3a3a3; }
  }

  .comment-content { font-size: 14px; color: #404040; line-height: 1.6; word-break: break-word; }
}

.empty-comments { text-align: center; padding: 32px; color: #a3a3a3; font-size: 14px; }

.load-more {
  text-align: center; margin-top: 16px; padding-top: 12px;
  border-top: 1px solid #f5f5f5;
}
</style>
