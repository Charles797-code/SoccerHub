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
  if (path.startsWith('/api/')) return path
  return '/api' + path
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
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;

  h1 {
    margin: 0;
    font-size: 24px;
    color: #262626;
  }
}

.headline-card {
  display: flex;
  gap: 24px;
  padding: 20px;
  background: linear-gradient(135deg, #1a56db 0%, #3b82f6 100%);
  border-radius: 14px;
  cursor: pointer;
  margin-bottom: 24px;
  transition: transform 0.2s;

  &:hover {
    transform: translateY(-2px);
  }

  .headline-image {
    width: 280px;
    height: 180px;
    border-radius: 10px;
    overflow: hidden;
    flex-shrink: 0;

    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }

    .headline-placeholder {
      width: 100%;
      height: 100%;
      background: rgba(255, 255, 255, 0.15);
      display: flex;
      align-items: center;
      justify-content: center;
      color: rgba(255, 255, 255, 0.5);
    }
  }

  .headline-content {
    flex: 1;
    min-width: 0;
    display: flex;
    flex-direction: column;
    justify-content: center;

    .headline-badge {
      display: inline-block;
      width: fit-content;
      padding: 2px 12px;
      border-radius: 4px;
      background: #f59e0b;
      color: #fff;
      font-size: 12px;
      font-weight: 600;
      margin-bottom: 10px;
    }

    h2 {
      margin: 0 0 10px;
      font-size: 20px;
      font-weight: 700;
      color: #ffffff;
      line-height: 1.4;
      display: -webkit-box;
      -webkit-line-clamp: 2;
      -webkit-box-orient: vertical;
      overflow: hidden;
    }

    .headline-summary {
      margin: 0 0 12px;
      font-size: 14px;
      color: rgba(255, 255, 255, 0.8);
      line-height: 1.5;
      display: -webkit-box;
      -webkit-line-clamp: 2;
      -webkit-box-orient: vertical;
      overflow: hidden;
    }

    .headline-meta {
      display: flex;
      align-items: center;
      gap: 12px;
      font-size: 12px;
      color: rgba(255, 255, 255, 0.7);

      .source-tag {
        background: rgba(255, 255, 255, 0.2);
        padding: 1px 8px;
        border-radius: 3px;
      }
    }
  }
}

.news-list {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.news-card {
  display: flex;
  gap: 16px;
  padding: 16px;
  background: #ffffff;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.2s;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);

  &:hover {
    box-shadow: 0 3px 10px rgba(0, 0, 0, 0.1);
  }

  .news-image {
    width: 160px;
    height: 100px;
    border-radius: 8px;
    overflow: hidden;
    flex-shrink: 0;

    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }

    &.news-image-placeholder {
      background: #f0f4ff;
      display: flex;
      align-items: center;
      justify-content: center;
      color: #b3c6ff;
    }
  }

  .news-content {
    flex: 1;
    min-width: 0;

    h3 {
      margin: 0 0 8px;
      font-size: 15px;
      font-weight: 600;
      color: #262626;
      line-height: 1.4;
      display: -webkit-box;
      -webkit-line-clamp: 2;
      -webkit-box-orient: vertical;
      overflow: hidden;
    }

    .news-summary {
      margin: 0 0 8px;
      font-size: 13px;
      color: #737373;
      line-height: 1.5;
      display: -webkit-box;
      -webkit-line-clamp: 1;
      -webkit-box-orient: vertical;
      overflow: hidden;
    }

    .news-meta {
      display: flex;
      align-items: center;
      gap: 10px;
      font-size: 12px;
      color: #a3a3a3;

      .source-tag {
        background: rgba(26, 86, 219, 0.1);
        color: #1a56db;
        padding: 1px 6px;
        border-radius: 3px;
      }
    }
  }
}

.pagination-wrapper {
  display: flex;
  justify-content: center;
  margin-top: 24px;
}

.empty-state {
  text-align: center;
  padding: 40px;
  color: #737373;
  font-size: 14px;
  background: #ffffff;
  border-radius: 10px;

  p {
    margin: 12px 0;
  }
}

.loading-state {
  padding: 20px;
  background: #ffffff;
  border-radius: 10px;
}

@media (max-width: 768px) {
  .headline-card {
    flex-direction: column;

    .headline-image {
      width: 100%;
      height: 180px;
    }
  }

  .news-card {
    flex-direction: column;

    .news-image {
      width: 100%;
      height: 160px;
    }
  }
}
</style>
