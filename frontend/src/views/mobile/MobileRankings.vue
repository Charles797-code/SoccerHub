<template>
  <div class="mobile-rankings">
    <!-- Type Tabs -->
    <div class="type-tabs">
      <div
        v-for="tab in tabs"
        :key="tab.value"
        class="tab"
        :class="{ active: selectedType === tab.value }"
        @click="selectType(tab.value)"
      >
        {{ tab.label }}
      </div>
    </div>

    <!-- Players List -->
    <div class="rankings-list" v-if="rankings.length > 0">
      <div
        v-for="(player, index) in rankings"
        :key="player.playerId"
        class="rank-item"
        @click="router.push(`/m/players/${player.playerId}`)"
      >
        <span class="rank" :class="`rank-${index + 1}`">{{ index + 1 }}</span>
        <img
          v-if="player.avatarUrl"
          :src="getImageUrl(player.avatarUrl)"
          :alt="player.name"
          class="avatar"
        />
        <div v-else class="avatar avatar--placeholder">
          {{ (player.nameCn || player.name)?.charAt(0) }}
        </div>
        <div class="player-info">
          <span class="name">{{ player.nameCn || player.name }}</span>
          <span class="meta">
            {{ player.clubName || '未知俱乐部' }}
            <span v-if="player.position"> · {{ positionMap[player.position] }}</span>
          </span>
        </div>
        <div class="score-wrap">
          <span class="score">{{ Number(player.avgScore || player.score || 0).toFixed(1) }}</span>
          <span class="score-label">评分</span>
        </div>
      </div>
    </div>
    <div v-else class="empty">
      <TrendCharts class="empty-icon" />
      <p>暂无数据</p>
    </div>

    <!-- Load More -->
    <div v-if="hasMore && rankings.length > 0" class="load-more" @click="loadMore">
      加载更多
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { TrendCharts } from '@element-plus/icons-vue'
import { playerApi, clubApi } from '@/api'

const router = useRouter()

const rankings = ref<any[]>([])
const clubs = ref<any[]>([])
const selectedType = ref('score')
const page = ref(1)
const hasMore = ref(true)

const clubNameMap = ref<Record<number, string>>({})

const positionMap: Record<string, string> = {
  GK: '门将', DF: '后卫', MF: '中场', FW: '前锋'
}

const tabs = [
  { label: '评分', value: 'score' },
  { label: '进球', value: 'goals' },
  { label: '助攻', value: 'assists' },
]

function getImageUrl(url: string) {
  if (!url) return ''
  if (url.startsWith('http://') || url.startsWith('https://')) return url
  if (url.startsWith('/uploads/')) return url
  return '/uploads/' + url.replace(/^\//, '')
}

function getClubName(clubId: number) {
  return clubNameMap.value[clubId] || ''
}

async function fetchClubs() {
  try {
    const res = await clubApi.list({ page: 1, pageSize: 100 })
    clubs.value = res.data.data?.records || []
    clubs.value.forEach((c: any) => {
      clubNameMap.value[c.clubId] = c.shortName || c.name
    })
  } catch (e) {
    console.error('加载俱乐部失败', e)
  }
}

function attachClubNames(items: any[]) {
  return items.map((item: any) => ({
    ...item,
    clubName: getClubName(item.clubId)
  }))
}

async function fetchRankings() {
  try {
    const res = await playerApi.getRankings({ page: page.value, pageSize: 30 })
    let data = res.data.data?.records || []
    data = attachClubNames(data)
    if (page.value === 1) {
      rankings.value = data
    } else {
      rankings.value = [...rankings.value, ...data]
    }
    hasMore.value = (res.data.data?.records?.length || 0) >= 30
  } catch (e) {
    console.error('加载排行榜失败', e)
  }
}

function selectType(type: string) {
  selectedType.value = type
  page.value = 1
  fetchRankings()
}

function loadMore() {
  page.value++
  fetchRankings()
}

onMounted(async () => {
  await fetchClubs()
  await fetchRankings()
})
</script>

<style scoped lang="scss">
.mobile-rankings {
  padding: 16px;
}

.type-tabs {
  display: flex;
  gap: 8px;
  margin-bottom: 16px;
}

.tab {
  padding: 8px 20px;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 20px;
  font-size: 13px;
  color: rgba(255, 255, 255, 0.6);
  cursor: pointer;
  transition: all 0.2s;

  &.active {
    background: linear-gradient(135deg, #7c3aed, #6d28d9);
    color: #fff;
  }
}

.rankings-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.rank-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  background: rgba(255, 255, 255, 0.03);
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.2s;

  &:active {
    background: rgba(255, 255, 255, 0.06);
  }
}

.rank {
  width: 28px;
  height: 28px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 13px;
  font-weight: 700;
  background: rgba(255, 255, 255, 0.1);
  color: rgba(255, 255, 255, 0.6);
  flex-shrink: 0;

  &.rank-1 {
    background: linear-gradient(135deg, rgba(251, 191, 36, 0.3), rgba(251, 191, 36, 0.1));
    color: #fbbf24;
    box-shadow: 0 0 12px rgba(251, 191, 36, 0.2);
  }
  &.rank-2 {
    background: rgba(192, 192, 192, 0.2);
    color: #c0c0c0;
  }
  &.rank-3 {
    background: rgba(180, 83, 9, 0.2);
    color: #d97706;
  }
}

.avatar {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  object-fit: cover;
  flex-shrink: 0;

  &--placeholder {
    background: linear-gradient(135deg, rgba(124, 58, 237, 0.3), rgba(124, 58, 237, 0.1));
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 18px;
    font-weight: 700;
    color: #a78bfa;
  }
}

.player-info {
  flex: 1;
  min-width: 0;

  .name {
    display: block;
    font-size: 15px;
    font-weight: 600;
    color: #fff;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .meta {
    font-size: 12px;
    color: rgba(255, 255, 255, 0.5);
  }
}

.score-wrap {
  text-align: center;
  flex-shrink: 0;

  .score {
    display: block;
    font-size: 20px;
    font-weight: 700;
    background: linear-gradient(135deg, #fbbf24, #f59e0b);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
  }

  .score-label {
    font-size: 10px;
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
