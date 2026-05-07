<template>
  <div class="mobile-players">
    <!-- Search -->
    <div class="search-bar">
      <Search class="search-icon" />
      <input
        v-model="keyword"
        type="text"
        placeholder="搜索球员..."
        @input="handleSearch"
      />
    </div>

    <!-- Filter -->
    <div class="filter-row">
      <select v-model="positionFilter" class="filter-select" @change="fetchPlayers">
        <option value="">全部位置</option>
        <option value="GK">门将</option>
        <option value="DF">后卫</option>
        <option value="MF">中场</option>
        <option value="FW">前锋</option>
      </select>
      <select v-model="clubFilter" class="filter-select" @change="fetchPlayers">
        <option value="">全部俱乐部</option>
        <option v-for="club in clubs" :key="club.clubId" :value="club.clubId">
          {{ club.shortName || club.name }}
        </option>
      </select>
    </div>

    <!-- Players Grid -->
    <div class="players-grid" v-if="players.length > 0">
      <div
        v-for="player in players"
        :key="player.playerId"
        class="player-card"
        @click="router.push(`/m/players/${player.playerId}`)"
      >
        <img
          v-if="player.avatarUrl"
          :src="getImageUrl(player.avatarUrl)"
          :alt="player.name"
          class="player-avatar"
        />
        <div v-else class="player-avatar player-avatar--placeholder">
          {{ (player.nameCn || player.name)?.charAt(0) }}
        </div>
        <div class="player-info">
          <span class="name">{{ player.nameCn || player.name }}</span>
          <span class="meta">
            <span class="position-badge">{{ positionMap[player.position] }}</span>
            <span class="club">{{ getClubName(player.clubId) }}</span>
          </span>
        </div>
        <span class="score" v-if="player.avgScore">{{ Number(player.avgScore).toFixed(1) }}</span>
      </div>
    </div>
    <div v-else class="empty">
      <User class="empty-icon" />
      <p>暂无球员</p>
    </div>

    <!-- Load More -->
    <div v-if="hasMore && players.length > 0" class="load-more" @click="loadMore">
      加载更多
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { Search, User } from '@element-plus/icons-vue'
import { playerApi, clubApi } from '@/api'

const router = useRouter()
const route = useRoute()

const players = ref<any[]>([])
const clubs = ref<any[]>([])
const keyword = ref('')
const positionFilter = ref('')
const clubFilter = ref('')
const page = ref(1)
const hasMore = ref(true)

const clubNameMap = ref<Record<number, string>>({})

const positionMap: Record<string, string> = {
  GK: '门将', DF: '后卫', MF: '中场', FW: '前锋'
}

function getClubName(clubId: number) {
  return clubNameMap.value[clubId] || ''
}

function getImageUrl(url: string) {
  if (!url) return ''
  if (url.startsWith('http://') || url.startsWith('https://')) return url
  if (url.startsWith('/uploads/')) return url
  return '/uploads/' + url.replace(/^\//, '')
}

function handleSearch() {
  page.value = 1
  fetchPlayers()
}

async function fetchPlayers() {
  try {
    const params: any = {
      page: page.value,
      pageSize: 20,
      keyword: keyword.value || undefined,
      position: positionFilter.value || undefined,
      clubId: clubFilter.value || undefined
    }
    const res = await playerApi.list(params)
    if (page.value === 1) {
      players.value = res.data.data?.records || []
    } else {
      players.value = [...players.value, ...(res.data.data?.records || [])]
    }
    hasMore.value = (res.data.data?.records?.length || 0) >= 20
  } catch (e) {
    console.error('加载球员失败', e)
  }
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

function loadMore() {
  page.value++
  fetchPlayers()
}

onMounted(async () => {
  await fetchClubs()

  // Support keyword from query
  if (route.query.keyword) {
    keyword.value = route.query.keyword as string
  }

  await fetchPlayers()
})
</script>

<style scoped lang="scss">
.mobile-players {
  padding: 16px;
}

.search-bar {
  display: flex;
  align-items: center;
  gap: 10px;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 10px;
  padding: 10px 14px;
  margin-bottom: 12px;

  .search-icon {
    font-size: 18px;
    color: rgba(255, 255, 255, 0.4);
  }

  input {
    flex: 1;
    background: none;
    border: none;
    outline: none;
    font-size: 14px;
    color: #fff;

    &::placeholder {
      color: rgba(255, 255, 255, 0.4);
    }
  }
}

.filter-row {
  display: flex;
  gap: 10px;
  margin-bottom: 16px;
}

.filter-select {
  flex: 1;
  padding: 10px 12px;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 10px;
  color: #fff;
  font-size: 13px;
  outline: none;

  option {
    background: #1a1a2e;
    color: #fff;
  }
}

.players-grid {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.player-card {
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

.player-avatar {
  width: 48px;
  height: 48px;
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
    display: flex;
    align-items: center;
    gap: 8px;
    margin-top: 4px;
  }

  .position-badge {
    font-size: 11px;
    padding: 2px 8px;
    background: rgba(124, 58, 237, 0.2);
    color: #a78bfa;
    border-radius: 10px;
  }

  .club {
    font-size: 12px;
    color: rgba(255, 255, 255, 0.5);
  }
}

.score {
  font-size: 20px;
  font-weight: 700;
  background: linear-gradient(135deg, #fbbf24, #f59e0b);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  flex-shrink: 0;
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
