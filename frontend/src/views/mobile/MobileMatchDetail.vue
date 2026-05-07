<template>
  <div class="mobile-match-detail">
    <!-- Loading -->
    <div v-if="loading" class="loading">
      <div class="spinner"></div>
    </div>

    <!-- Content -->
    <template v-else-if="match">
      <!-- Header -->
      <div class="match-header">
        <div class="back-btn" @click="router.back()">
          <el-icon><ArrowLeft /></el-icon>
        </div>
        <div class="league-badge">
          <span class="league-dot" :style="{ background: getLeagueColor(match.league) }"></span>
          {{ match.league || '比赛' }}
        </div>
        <div class="status-badge" :class="getStatusClass(match.status)">
          {{ getStatusLabel(match.status) }}
          <span v-if="match.liveMinute" class="live-minute">{{ match.liveMinute }}</span>
        </div>
      </div>

      <!-- Teams & Score -->
      <div class="score-section">
        <div class="team home-team">
          <img
            v-if="getClubLogo(match.homeClubId)"
            :src="getImageUrl(getClubLogo(match.homeClubId))"
            :alt="getClubName(match.homeClubId)"
            class="team-logo"
            @click="router.push(`/m/clubs/${match.homeClubId}`)"
          />
          <div v-else class="team-logo team-logo--placeholder" @click="router.push(`/m/clubs/${match.homeClubId}`)">
            {{ getClubName(match.homeClubId)?.charAt(0) }}
          </div>
          <span class="team-name">{{ getClubName(match.homeClubId) }}</span>
        </div>

        <div class="score-display">
          <span class="score">{{ match.homeScore ?? 0 }}</span>
          <span class="score-sep">:</span>
          <span class="score">{{ match.awayScore ?? 0 }}</span>
        </div>

        <div class="team away-team">
          <img
            v-if="getClubLogo(match.awayClubId)"
            :src="getImageUrl(getClubLogo(match.awayClubId))"
            :alt="getClubName(match.awayClubId)"
            class="team-logo"
            @click="router.push(`/m/clubs/${match.awayClubId}`)"
          />
          <div v-else class="team-logo team-logo--placeholder" @click="router.push(`/m/clubs/${match.awayClubId}`)">
            {{ getClubName(match.awayClubId)?.charAt(0) }}
          </div>
          <span class="team-name">{{ getClubName(match.awayClubId) }}</span>
        </div>
      </div>

      <!-- Match Info -->
      <div class="match-info">
        <div class="info-row">
          <span class="info-label">时间</span>
          <span class="info-value">{{ formatDateTime(match.matchTime) }}</span>
        </div>
        <div class="info-row" v-if="match.round">
          <span class="info-label">轮次</span>
          <span class="info-value">{{ match.round }}</span>
        </div>
        <div class="info-row" v-if="match.venue">
          <span class="info-label">球场</span>
          <span class="info-value">{{ match.venue }}</span>
        </div>
        <div class="info-row" v-if="match.referee">
          <span class="info-label">裁判</span>
          <span class="info-value">{{ match.referee }}</span>
        </div>
      </div>

      <!-- Events -->
      <div class="events-section" v-if="events.length > 0">
        <h3 class="section-title">比赛事件</h3>
        <div class="events-list">
          <div v-for="event in events" :key="event.eventId" class="event-item" :class="event.clubId === match.homeClubId ? 'event--home' : 'event--away'">
            <span class="event-minute">{{ event.minute }}'</span>
            <span class="event-type" :class="`event-type--${event.eventType.toLowerCase()}`">
              {{ getEventTypeLabel(event.eventType) }}
            </span>
            <span class="event-player">{{ event.playerName }}</span>
            <span v-if="event.assistPlayerName" class="event-assist">助攻: {{ event.assistPlayerName }}</span>
          </div>
        </div>
      </div>

      <!-- Rating Section -->
      <div class="rating-section" v-if="authStore.isLoggedIn && match.status === 'FINISHED'">
        <h3 class="section-title">评分球员</h3>
        <div class="rating-tabs">
          <div
            v-for="tab in ['home', 'away']"
            :key="tab"
            class="rating-tab"
            :class="{ active: ratingTab === tab }"
            @click="ratingTab = tab"
          >
            {{ tab === 'home' ? getClubName(match.homeClubId) : getClubName(match.awayClubId) }}
          </div>
        </div>
        <div class="rating-players">
          <div
            v-for="player in ratingPlayers"
            :key="player.playerId"
            class="rating-player"
          >
            <span class="player-name">{{ player.nameCn || player.name }}</span>
            <div class="star-input" @click="setRating(player.playerId, $event)">
              <span v-for="n in 5" :key="n" class="star" :class="{ active: n <= (playerRatings[player.playerId] || 0) }">
                <el-icon><Star /></el-icon>
              </span>
            </div>
          </div>
        </div>
        <button class="submit-btn" @click="submitRatings" :disabled="submitting">
          {{ submitting ? '提交中...' : '提交评分' }}
        </button>
      </div>

      <!-- Comments -->
      <div class="comments-section">
        <h3 class="section-title">评论区</h3>
        <div class="comment-input" v-if="authStore.isLoggedIn">
          <textarea v-model="commentText" placeholder="发表你的看法..." rows="2"></textarea>
          <button @click="submitComment">发送</button>
        </div>
        <div class="comments-list">
          <div v-for="comment in comments" :key="comment.commentId" class="comment-item">
            <img
              v-if="comment.userAvatar"
              :src="getImageUrl(comment.userAvatar)"
              :alt="comment.userNickname"
              class="comment-avatar"
            />
            <div v-else class="comment-avatar comment-avatar--placeholder">
              {{ comment.userNickname?.charAt(0) || 'U' }}
            </div>
            <div class="comment-content">
              <span class="comment-user">{{ comment.userNickname }}</span>
              <p class="comment-text">{{ comment.content }}</p>
              <span class="comment-time">{{ formatTime(comment.createdAt) }}</span>
            </div>
          </div>
        </div>
        <div v-if="comments.length === 0" class="empty-comments">暂无评论</div>
      </div>
    </template>

    <!-- Error -->
    <div v-else class="error">
      <p>加载失败</p>
      <button @click="fetchMatch">重试</button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ArrowLeft, Star } from '@element-plus/icons-vue'
import { matchApi, clubApi, playerApi } from '@/api'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()

const match = ref<any>(null)
const events = ref<any[]>([])
const comments = ref<any[]>([])
const loading = ref(true)
const ratingTab = ref('home')
const playerRatings = ref<Record<number, number>>({})
const submitting = ref(false)
const commentText = ref('')

const clubNameMap = ref<Record<number, string>>({})
const clubLogoMap = ref<Record<number, string>>({})
const players = ref<any[]>([])

const leagueColors: Record<string, string> = {
  'La Liga': '#e8a317',
  'Premier League': '#3d195b',
  'Bundesliga': '#d20515',
  'Serie A': '#024494',
  'Ligue 1': '#dda0dd',
}

function getLeagueColor(league: string) {
  return leagueColors[league] || '#7c3aed'
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

function formatDateTime(time: string) {
  if (!time) return '-'
  return new Date(time).toLocaleString('zh-CN', {
    year: 'numeric', month: 'short', day: 'numeric',
    hour: '2-digit', minute: '2-digit', hour12: false
  })
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
    IN_PROGRESS: 'status--live', LIVE: 'status--live', FINISHED: 'status--finished'
  }
  return map[status] || ''
}

function getEventTypeLabel(type: string) {
  const map: Record<string, string> = {
    GOAL: '进球', PENALTY: '点球', OWN_GOAL: '乌龙', YELLOW_CARD: '黄牌', RED_CARD: '红牌', SUBSTITUTE: '换人'
  }
  return map[type] || type
}

const ratingPlayers = computed(() => {
  const clubId = ratingTab.value === 'home' ? match.value?.homeClubId : match.value?.awayClubId
  return players.value.filter((p: any) => p.clubId === clubId)
})

function setRating(playerId: number, event: MouseEvent) {
  const target = event.currentTarget as HTMLElement
  const stars = target.querySelectorAll('.star')
  let rating = 0
  stars.forEach((star, index) => {
    const rect = star.getBoundingClientRect()
    if (event.clientX <= rect.left + rect.width / 2) {
      rating = index + 1
    }
  })
  if (rating === 0) rating = 5
  playerRatings.value[playerId] = rating
}

async function submitRatings() {
  submitting.value = true
  try {
    for (const [playerId, score] of Object.entries(playerRatings.value)) {
      await playerApi.rate(Number(playerId), { score: score as number })
    }
    ElMessage.success('评分成功')
    playerRatings.value = {}
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '评分失败')
  } finally {
    submitting.value = false
  }
}

async function submitComment() {
  if (!commentText.value.trim()) return
  try {
    await matchApi.comment(match.value.matchId, { content: commentText.value })
    ElMessage.success('评论成功')
    commentText.value = ''
    fetchComments()
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '评论失败')
  }
}

async function fetchMatch() {
  loading.value = true
  try {
    const matchId = route.params.id as string
    const res = await matchApi.getById(matchId)
    match.value = res.data.data

    // Fetch clubs
    const clubRes = await clubApi.list({ page: 1, pageSize: 100 })
    clubRes.data.data?.records?.forEach((c: any) => {
      clubNameMap.value[c.clubId] = c.shortName || c.name
      clubLogoMap.value[c.clubId] = c.logoUrl || c.logo || ''
    })

    // Fetch events
    try {
      const eventsRes = await matchApi.getEvents(matchId)
      events.value = eventsRes.data.data || []
    } catch {
      events.value = []
    }

    // Fetch players
    const playersRes = await playerApi.list({ page: 1, pageSize: 100 })
    players.value = playersRes.data.data?.records || []

    await fetchComments()
  } catch (e) {
    console.error('加载比赛失败', e)
  } finally {
    loading.value = false
  }
}

async function fetchComments() {
  try {
    const res = await matchApi.getComments(match.value.matchId)
    comments.value = res.data.data || []
  } catch {
    comments.value = []
  }
}

onMounted(() => {
  authStore.initAuth()
  fetchMatch()
})
</script>

<style scoped lang="scss">
.mobile-match-detail {
  min-height: 100vh;
  background: #0a0a0f;
  color: #fff;
  padding-bottom: 20px;
}

.loading {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 50vh;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 3px solid rgba(124, 58, 237, 0.2);
  border-top-color: #7c3aed;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.match-header {
  position: relative;
  padding: 16px;
  text-align: center;
  background: linear-gradient(180deg, rgba(124, 58, 237, 0.1) 0%, transparent 100%);
}

.back-btn {
  position: absolute;
  top: 12px;
  left: 16px;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.1);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  z-index: 10;

  &:active {
    background: rgba(255, 255, 255, 0.2);
  }
}

.league-badge {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  color: rgba(255, 255, 255, 0.6);
  margin-bottom: 8px;

  .league-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
  }
}

.status-badge {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  font-weight: 600;
  padding: 4px 12px;
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.1);
  color: rgba(255, 255, 255, 0.7);

  &.status--live {
    background: rgba(239, 68, 68, 0.15);
    color: #ef4444;
  }

  &.status--finished {
    background: rgba(34, 197, 94, 0.15);
    color: #22c55e;
  }

  .live-minute {
    font-size: 11px;
  }
}

.score-section {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 24px 16px;
}

.team {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
  flex: 1;
}

.team-logo {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  object-fit: cover;
  cursor: pointer;

  &--placeholder {
    background: rgba(124, 58, 237, 0.2);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 24px;
    font-weight: 700;
    color: #a78bfa;
  }
}

.team-name {
  font-size: 14px;
  font-weight: 600;
  color: #fff;
  text-align: center;
  max-width: 100px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.score-display {
  display: flex;
  align-items: center;
  gap: 4px;

  .score {
    font-size: 36px;
    font-weight: 700;
    color: #fff;
  }

  .score-sep {
    font-size: 24px;
    color: rgba(255, 255, 255, 0.3);
  }
}

.match-info {
  margin: 0 16px 20px;
  background: rgba(255, 255, 255, 0.03);
  border-radius: 12px;
  overflow: hidden;
}

.info-row {
  display: flex;
  justify-content: space-between;
  padding: 12px 16px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);

  &:last-child {
    border-bottom: none;
  }
}

.info-label {
  font-size: 13px;
  color: rgba(255, 255, 255, 0.5);
}

.info-value {
  font-size: 13px;
  color: #fff;
}

.section-title {
  font-size: 16px;
  font-weight: 600;
  margin: 0 0 12px;
  padding: 0 16px;
}

.events-section {
  margin-bottom: 20px;
}

.events-list {
  padding: 0 16px;
}

.event-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px;
  background: rgba(255, 255, 255, 0.03);
  border-radius: 8px;
  margin-bottom: 8px;

  &.event--away {
    flex-direction: row-reverse;
  }
}

.event-minute {
  font-size: 12px;
  font-weight: 600;
  color: #7c3aed;
  min-width: 32px;
}

.event-type {
  font-size: 11px;
  padding: 2px 8px;
  border-radius: 10px;
  font-weight: 600;

  &--goal { background: rgba(34, 197, 94, 0.2); color: #22c55e; }
  &--penalty { background: rgba(251, 191, 36, 0.2); color: #fbbf24; }
  &--own_goal { background: rgba(239, 68, 68, 0.2); color: #ef4444; }
  &--yellow_card { background: rgba(251, 191, 36, 0.2); color: #fbbf24; }
  &--red_card { background: rgba(239, 68, 68, 0.2); color: #ef4444; }
}

.event-player {
  font-size: 13px;
  color: #fff;
  flex: 1;
}

.event-assist {
  font-size: 11px;
  color: rgba(255, 255, 255, 0.4);
}

.rating-section {
  margin-bottom: 20px;
}

.rating-tabs {
  display: flex;
  padding: 0 16px;
  gap: 8px;
  margin-bottom: 12px;
}

.rating-tab {
  flex: 1;
  text-align: center;
  padding: 10px;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 10px;
  font-size: 13px;
  color: rgba(255, 255, 255, 0.6);
  cursor: pointer;

  &.active {
    background: #7c3aed;
    color: #fff;
  }
}

.rating-players {
  padding: 0 16px;
}

.rating-player {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 10px 0;
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);

  &:last-child {
    border-bottom: none;
  }
}

.player-name {
  font-size: 14px;
  color: #fff;
}

.star-input {
  display: flex;
  gap: 4px;
}

.star {
  font-size: 20px;
  color: rgba(255, 255, 255, 0.2);
  cursor: pointer;

  &.active {
    color: #fbbf24;
  }
}

.submit-btn {
  display: block;
  width: calc(100% - 32px);
  margin: 16px;
  padding: 12px;
  background: linear-gradient(135deg, #7c3aed, #6d28d9);
  border: none;
  border-radius: 10px;
  color: #fff;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;

  &:disabled {
    opacity: 0.5;
  }
}

.comments-section {
  padding: 0 16px;
}

.comment-input {
  display: flex;
  gap: 10px;
  margin-bottom: 16px;

  textarea {
    flex: 1;
    padding: 12px;
    background: rgba(255, 255, 255, 0.05);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 10px;
    color: #fff;
    font-size: 14px;
    resize: none;
    outline: none;

    &::placeholder {
      color: rgba(255, 255, 255, 0.4);
    }
  }

  button {
    padding: 12px 20px;
    background: #7c3aed;
    border: none;
    border-radius: 10px;
    color: #fff;
    font-size: 14px;
    cursor: pointer;
  }
}

.comments-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.comment-item {
  display: flex;
  gap: 10px;
}

.comment-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  object-fit: cover;
  flex-shrink: 0;

  &--placeholder {
    background: linear-gradient(135deg, #7c3aed, #6d28d9);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 14px;
    font-weight: 600;
    color: #fff;
  }
}

.comment-content {
  flex: 1;
}

.comment-user {
  font-size: 13px;
  font-weight: 600;
  color: #a78bfa;
}

.comment-text {
  margin: 4px 0;
  font-size: 14px;
  color: #fff;
  line-height: 1.4;
}

.comment-time {
  font-size: 11px;
  color: rgba(255, 255, 255, 0.4);
}

.empty-comments {
  text-align: center;
  padding: 24px;
  color: rgba(255, 255, 255, 0.4);
  font-size: 14px;
}

.error {
  text-align: center;
  padding: 48px 16px;
  color: rgba(255, 255, 255, 0.6);

  button {
    margin-top: 16px;
    padding: 10px 24px;
    background: #7c3aed;
    border: none;
    border-radius: 20px;
    color: #fff;
    cursor: pointer;
  }
}
</style>
