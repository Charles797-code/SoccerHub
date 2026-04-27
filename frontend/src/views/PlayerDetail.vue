<template>
  <div class="page-container">
    <div v-if="player" class="player-detail">
      <div class="player-banner">
        <div class="banner-overlay"></div>
        <div class="banner-content">
          <div class="player-avatar">
            <img v-if="player.avatarUrl" :src="getImageUrl(player.avatarUrl)" alt="头像" />
            <span v-else>{{ (player.nameCn || player.name)?.charAt(0) }}</span>
          </div>
          <div class="player-meta">
            <h1>{{ player.nameCn || player.name }}</h1>
            <div class="meta-row">
              <span class="position-badge">{{ positionMap[player.position] || player.position }}</span>
              <span class="club-name">{{ player.clubName }}</span>
              <span class="jersey-number" v-if="player.jerseyNumber">#{{ player.jerseyNumber }}</span>
            </div>
          </div>
        </div>
      </div>

      <div class="detail-content">
        <div class="score-section">
          <div class="score-card">
            <div class="score-circle">
              <span class="score-value">{{ player.avgScore != null ? Number(player.avgScore).toFixed(1) : '-' }}</span>
              <span class="score-label">平均评分</span>
            </div>
          </div>
          <div class="stats-row">
            <div class="stat-item">
              <span class="stat-value">{{ player.totalRatings ?? 0 }}</span>
              <span class="stat-label">评分次数</span>
            </div>
            <div class="stat-item">
              <span class="stat-value">{{ player.highestScore != null ? Number(player.highestScore).toFixed(1) : '-' }}</span>
              <span class="stat-label">最高评分</span>
            </div>
            <div class="stat-item">
              <span class="stat-value">{{ player.lowestScore != null ? Number(player.lowestScore).toFixed(1) : '-' }}</span>
              <span class="stat-label">最低评分</span>
            </div>
          </div>
        </div>

        <div class="info-section">
          <h3>球员信息</h3>
          <div class="info-grid">
            <div class="info-item">
              <span class="info-label">中文名</span>
              <span class="info-value">{{ player.nameCn || '-' }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">英文名</span>
              <span class="info-value">{{ player.name }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">位置</span>
              <span class="info-value">{{ positionMap[player.position] || player.position }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">俱乐部</span>
              <span class="info-value">{{ player.clubName }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">球衣号码</span>
              <span class="info-value">{{ player.jerseyNumber || '-' }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">国籍</span>
              <span class="info-value">{{ player.nationality || '-' }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">年龄</span>
              <span class="info-value">{{ player.age || '-' }}</span>
            </div>
          </div>
        </div>

        <div class="rating-section">
          <h3>为该球员评分</h3>
          <div class="rating-form">
            <el-rate v-model="ratingScore" :max="10" :allow-half="true" show-score />
            <AppButton type="primary" :loading="ratingLoading" @click="submitRating">
              提交评分
            </AppButton>
          </div>
        </div>
      </div>
    </div>

    <div v-else class="loading-state">
      <el-skeleton :rows="8" animated />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { playerApi, ratingApi } from '@/api'
import AppButton from '@/components/AppButton.vue'

const route = useRoute()
const player = ref<any>(null)
const ratingScore = ref(5)
const ratingLoading = ref(false)

const positionMap: Record<string, string> = {
  GK: '守门员',
  DF: '后卫',
  MF: '中场',
  FW: '前锋'
}

onMounted(async () => {
  const playerId = Number(route.params.id)
  try {
    const res = await playerApi.getById(playerId)
    player.value = res.data.data
  } catch (e) {
    console.error(e)
  }
})

async function submitRating() {
  const playerId = Number(route.params.id)
  if (!player.value?.clubId) {
    ElMessage.error('无法获取球员所属俱乐部')
    return
  }
  try {
    ratingLoading.value = true
    await ratingApi.submit({ 
      targetType: 'PLAYER', 
      targetId: playerId, 
      score: ratingScore.value,
      clubId: player.value.clubId
    })
    ElMessage.success('评分成功！')

    const res = await playerApi.getById(playerId)
    player.value = res.data.data
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '评分失败')
  } finally {
    ratingLoading.value = false
  }
}

function getImageUrl(path: string) {
  if (!path) return ''
  if (path.startsWith('http://') || path.startsWith('https://')) return path
  if (path.startsWith('/uploads/')) return path
  return '/uploads/' + path.replace(/^\//, '')
}
</script>

<style scoped lang="scss">
@use '@/styles/tokens' as *;

.loading-state {
  padding: $space-6;
  background: $surface-card;
  border: 1px solid $border-subtle;
  border-radius: $radius-xl;
}
</style>
