<template>
  <div class="mobile-news">
    <!-- Header -->
    <div class="page-header">
      <h2>足球资讯</h2>
    </div>

    <!-- News List -->
    <div class="news-list">
      <div
        v-for="news in newsList"
        :key="news.articleId"
        class="news-item"
        @click="router.push(`/m/news/${news.articleId}`)"
      >
        <img
          v-if="news.coverImageUrl"
          :src="getImageUrl(news.coverImageUrl)"
          :alt="news.title"
          class="news-image"
        />
        <div v-else class="news-image news-image--placeholder">
          <el-icon><Document /></el-icon>
        </div>
        <div class="news-content">
          <h3 class="news-title">{{ news.title }}</h3>
          <p v-if="news.summary" class="news-summary">{{ news.summary }}</p>
          <div class="news-meta">
            <span v-if="news.sourceName" class="source-tag">{{ news.sourceName }}</span>
            <span class="meta-item">{{ news.viewCount || 0 }} 阅读</span>
          </div>
        </div>
      </div>
    </div>

    <div v-if="newsList.length === 0 && !loading" class="empty">
      <el-icon class="empty-icon"><Document /></el-icon>
      <p>暂无资讯</p>
    </div>

    <div v-if="loading" class="loading">
      <el-icon class="is-loading"><Loading /></el-icon>
      加载中...
    </div>

    <!-- Load More -->
    <div v-if="hasMore && newsList.length > 0" class="load-more" @click="loadMore">
      加载更多
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Document, Loading } from '@element-plus/icons-vue'
import { newsApi } from '@/api'

const router = useRouter()

const newsList = ref<any[]>([])
const currentPage = ref(1)
const pageSize = ref(20)
const hasMore = ref(true)
const loading = ref(false)

function getImageUrl(url: string) {
  if (!url) return ''
  if (url.startsWith('http://') || url.startsWith('https://')) return url
  if (url.startsWith('/uploads/')) return url
  return '/uploads/' + url.replace(/^\//, '')
}

async function fetchNews(append = false) {
  if (!append) loading.value = true
  try {
    const res = await newsApi.list({
      page: currentPage.value,
      pageSize: pageSize.value
    })
    const records = res.data.data?.records || []
    if (append) {
      newsList.value = [...newsList.value, ...records]
    } else {
      newsList.value = records
    }
    hasMore.value = records.length >= pageSize.value
  } catch (e) {
    console.error('加载新闻失败', e)
  } finally {
    loading.value = false
  }
}

function loadMore() {
  currentPage.value++
  fetchNews(true)
}

onMounted(() => {
  fetchNews()
})
</script>

<style scoped lang="scss">
@use '@/styles/tokens' as *;

.mobile-news {
  padding: 16px;
  padding-bottom: 80px;
}

.page-header {
  margin-bottom: 16px;

  h2 {
    margin: 0;
    font-size: 22px;
    font-weight: 700;
    color: #fff;
  }
}

.news-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.news-item {
  display: flex;
  gap: 12px;
  padding: 12px;
  background: rgba(255, 255, 255, 0.03);
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.2s;

  &:active {
    background: rgba(255, 255, 255, 0.06);
    transform: scale(0.98);
  }
}

.news-image {
  width: 100px;
  height: 75px;
  border-radius: 8px;
  object-fit: cover;
  flex-shrink: 0;

  &--placeholder {
    background: rgba($purple-primary, 0.1);
    display: flex;
    align-items: center;
    justify-content: center;
    color: $purple-light;
    font-size: 28px;
  }
}

.news-content {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.news-title {
  margin: 0 0 6px;
  font-size: 14px;
  font-weight: 600;
  color: #fff;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.news-summary {
  margin: 0 0 6px;
  font-size: 12px;
  color: $text-muted;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.news-meta {
  display: flex;
  align-items: center;
  gap: 8px;
}

.source-tag {
  padding: 1px 6px;
  background: rgba($purple-primary, 0.15);
  border-radius: 10px;
  font-size: 10px;
  color: $purple-light;
  font-weight: 500;
}

.meta-item {
  font-size: 11px;
  color: $text-muted;
}

.empty {
  text-align: center;
  padding: 48px 16px;
  color: $text-muted;

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

.loading {
  text-align: center;
  padding: 32px;
  color: $text-muted;

  .el-icon {
    font-size: 24px;
    margin-bottom: 8px;
    display: block;
  }
}

.load-more {
  text-align: center;
  padding: 16px;
  color: $purple-light;
  font-size: 14px;
  cursor: pointer;

  &:active {
    opacity: 0.7;
  }
}
</style>
