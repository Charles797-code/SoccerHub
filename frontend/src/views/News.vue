<template>
  <div class="page-container">
    <div class="page-header">
      <h1>足球头条</h1>
      <el-button v-if="isAdmin" type="primary" :loading="scraping" @click="handleScrape">
        <el-icon><Refresh /></el-icon>
        抓取最新新闻
      </el-button>
    </div>

    <div v-if="topNews" class="headline-card" @click="goToNews(topNews.articleId)">
      <div class="headline-image" v-if="topNews.coverImageUrl">
        <img :src="getImageUrl(topNews.coverImageUrl)" :alt="topNews.title" />
      </div>
      <div class="headline-image" v-else>
        <div class="headline-placeholder">
          <el-icon :size="48"><Document /></el-icon>
        </div>
      </div>
      <div class="headline-content">
        <div class="headline-badge">头条</div>
        <h2>{{ topNews.title }}</h2>
        <p class="headline-summary">{{ topNews.summary || '点击查看详情...' }}</p>
        <div class="headline-meta">
          <span v-if="topNews.sourceName" class="source-tag">{{ topNews.sourceName }}</span>
          <span class="meta-item">{{ formatDate(topNews.publishedAt) }}</span>
          <span class="meta-item">{{ topNews.viewCount || 0 }} 阅读</span>
        </div>
      </div>
    </div>

    <div class="news-list">
      <div v-for="news in newsList" :key="news.articleId" class="news-card" @click="goToNews(news.articleId)">
        <div class="news-image" v-if="news.coverImageUrl">
          <img :src="getImageUrl(news.coverImageUrl)" :alt="news.title" />
        </div>
        <div class="news-image news-image-placeholder" v-else>
          <el-icon :size="28"><Document /></el-icon>
        </div>
        <div class="news-content">
          <h3>{{ news.title }}</h3>
          <p class="news-summary" v-if="news.summary">{{ news.summary }}</p>
          <div class="news-meta">
            <span v-if="news.sourceName" class="source-tag">{{ news.sourceName }}</span>
            <span class="meta-item">{{ formatDate(news.publishedAt) }}</span>
            <span class="meta-item">{{ news.viewCount || 0 }} 阅读</span>
          </div>
        </div>
      </div>
    </div>

    <div v-if="newsList.length === 0 && !loading" class="empty-state">
      <el-icon :size="48" color="#d9d9d9"><Document /></el-icon>
      <p>暂无新闻资讯</p>
      <el-button v-if="isAdmin" type="primary" @click="handleScrape">抓取新闻</el-button>
    </div>

    <div v-if="loading" class="loading-state">
      <el-skeleton :rows="5" animated />
    </div>

    <div class="pagination-wrapper">
      <el-pagination v-model:current-page="currentPage" :page-size="pageSize" :total="total"
        layout="prev, pager, next" @current-change="fetchNews" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Document, Refresh } from '@element-plus/icons-vue'
import { newsApi } from '@/api'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const newsList = ref<any[]>([])
const currentPage = ref(1)
const pageSize = ref(20)
const total = ref(0)
const loading = ref(false)
const scraping = ref(false)

const isAdmin = computed(() => {
  const role = authStore.user?.role
  return role === 'SUPER_ADMIN' || role === 'CLUB_ADMIN'
})

const topNews = computed(() => {
  return newsList.value.length > 0 ? newsList.value[0] : null
})

onMounted(() => {
  fetchNews()
})

async function fetchNews() {
  loading.value = true
  try {
    const res = await newsApi.list({
      page: currentPage.value,
      pageSize: pageSize.value
    })
    newsList.value = res.data.data?.records || []
    total.value = res.data.data?.total || 0
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
}

async function handleScrape() {
  scraping.value = true
  try {
    const res = await newsApi.scrape()
    const count = res.data.data?.length || 0
    ElMessage.success(`成功抓取 ${count} 条新闻`)
    currentPage.value = 1
    await fetchNews()
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '抓取失败')
  } finally {
    scraping.value = false
  }
}

function goToNews(articleId: number) {
  router.push(`/news/${articleId}`)
}

function getImageUrl(path: string) {
  if (!path) return ''
  if (path.startsWith('http://') || path.startsWith('https://')) return path
  if (path.startsWith('/uploads/')) return path
  return '/uploads/' + path.replace(/^\//, '')
}

function formatDate(time: string) {
  if (!time) return ''
  return new Date(time).toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}
</script>

<style scoped lang="scss">
@use '@/styles/tokens' as *;

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: $space-5;

  h1 {
    margin: 0;
    font-family: $font-display;
    font-size: $font-size-2xl;
    font-weight: $font-weight-bold;
    color: $text-primary;
    letter-spacing: $letter-spacing-tight;
  }
}
</style>
