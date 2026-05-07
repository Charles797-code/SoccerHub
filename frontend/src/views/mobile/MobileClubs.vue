<template>
  <div class="mobile-clubs">
    <!-- Filter Tabs -->
    <div class="filter-tabs">
      <div
        v-for="league in leagues"
        :key="league"
        class="tab"
        :class="{ active: selectedLeague === league }"
        @click="selectLeague(league)"
      >
        {{ getLeagueShort(league) }}
      </div>
    </div>

    <!-- Search -->
    <div class="search-bar">
      <Search class="search-icon" />
      <input
        v-model="keyword"
        type="text"
        placeholder="搜索俱乐部..."
        @input="handleSearch"
      />
    </div>

    <!-- Clubs Grid -->
    <div class="clubs-grid" v-if="filteredClubs.length > 0">
      <div
        v-for="club in filteredClubs"
        :key="club.clubId"
        class="club-card"
        @click="router.push(`/m/clubs/${club.clubId}`)"
      >
        <img
          v-if="club.logoUrl || club.logo"
          :src="getImageUrl(club.logoUrl || club.logo)"
          :alt="club.name"
          class="club-logo"
        />
        <div v-else class="club-logo club-logo--placeholder">
          {{ club.shortName?.charAt(0) || club.name?.charAt(0) }}
        </div>
        <span class="club-name">{{ club.shortName || club.name }}</span>
        <span class="club-league">{{ getLeagueShort(club.league) }}</span>
      </div>
    </div>
    <div v-else class="empty">
      <Tickets class="empty-icon" />
      <p>暂无俱乐部</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { Search, Tickets } from '@element-plus/icons-vue'
import { clubApi } from '@/api'

const router = useRouter()
const route = useRoute()

const clubs = ref<any[]>([])
const keyword = ref('')
const selectedLeague = ref('')

const leagueNameMap: Record<string, string> = {
  'La Liga': '西甲',
  'Premier League': '英超',
  'Bundesliga': '德甲',
  'Serie A': '意甲',
  'Ligue 1': '法甲'
}

const leagues = computed(() => {
  const set = new Set(clubs.value.map((c: any) => c.league))
  return ['', ...Array.from(set)]
})

function getLeagueShort(league: string) {
  return leagueNameMap[league] || league || '全部'
}

function getImageUrl(url: string) {
  if (!url) return ''
  if (url.startsWith('http://') || url.startsWith('https://')) return url
  if (url.startsWith('/uploads/')) return url
  return '/uploads/' + url.replace(/^\//, '')
}

function selectLeague(league: string) {
  selectedLeague.value = league
}

function handleSearch() {
  // Search is handled by filteredClubs computed
}

const filteredClubs = computed(() => {
  let result = clubs.value
  if (selectedLeague.value) {
    result = result.filter((c: any) => c.league === selectedLeague.value)
  }
  if (keyword.value.trim()) {
    const kw = keyword.value.toLowerCase()
    result = result.filter((c: any) =>
      (c.name && c.name.toLowerCase().includes(kw)) ||
      (c.shortName && c.shortName.toLowerCase().includes(kw))
    )
  }
  return result
})

onMounted(async () => {
  try {
    const res = await clubApi.list({ page: 1, pageSize: 100 })
    clubs.value = res.data.data?.records || []

    // Auto-select league from query
    if (route.query.league) {
      selectedLeague.value = route.query.league as string
    }
  } catch (e) {
    console.error('加载俱乐部失败', e)
  }
})
</script>

<style scoped lang="scss">
.mobile-clubs {
  padding: 16px;
}

.filter-tabs {
  display: flex;
  gap: 8px;
  overflow-x: auto;
  margin-bottom: 16px;
  padding-bottom: 4px;
  -webkit-overflow-scrolling: touch;

  &::-webkit-scrollbar {
    display: none;
  }
}

.tab {
  padding: 8px 16px;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 20px;
  font-size: 13px;
  color: rgba(255, 255, 255, 0.6);
  white-space: nowrap;
  cursor: pointer;
  transition: all 0.2s;
  flex-shrink: 0;

  &.active {
    background: #7c3aed;
    color: #fff;
  }
}

.search-bar {
  display: flex;
  align-items: center;
  gap: 10px;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 10px;
  padding: 10px 14px;
  margin-bottom: 16px;

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

.clubs-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
}

.club-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 16px 8px;
  background: rgba(255, 255, 255, 0.03);
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.2s;

  &:active {
    transform: scale(0.95);
    background: rgba(255, 255, 255, 0.06);
  }
}

.club-logo {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  object-fit: cover;

  &--placeholder {
    background: rgba(124, 58, 237, 0.2);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 20px;
    font-weight: 700;
    color: #a78bfa;
  }
}

.club-name {
  font-size: 12px;
  font-weight: 600;
  color: #fff;
  text-align: center;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  max-width: 100%;
}

.club-league {
  font-size: 10px;
  color: rgba(255, 255, 255, 0.4);
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

  p {
    margin: 0;
    font-size: 14px;
  }
}
</style>
