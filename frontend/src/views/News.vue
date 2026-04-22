<template>
  <div class="page-container">
    <div class="page-header">
      <h1>新闻资讯</h1>
    </div>

    <div class="news-list">
      <div v-for="news in newsList" :key="news.newsId" class="news-card" @click="goToNews(news.newsId)">
        <div class="news-image" v-if="news.imageUrl">
          <img :src="news.imageUrl" :alt="news.title" />
        </div>
        <div class="news-content">
          <div class="news-meta">
            <span class="news-category">{{ news.category }}</span>
            <span class="news-date">{{ formatDate(news.publishTime) }}</span>
          </div>
          <h3>{{ news.title }}</h3>
          <p class="news-summary">{{ news.summary }}</p>
        </div>
      </div>
    </div>

    <div v-if="newsList.length === 0" class="empty-state">暂无新闻资讯</div>

    <div class="pagination-wrapper">
      <el-pagination v-model:current-page="currentPage" :page-size="pageSize" :total="total"
        layout="prev, pager, next" @current-change="fetchNews" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { newsApi } from '@/api'

const router = useRouter()
const newsList = ref<any[]>([])
const currentPage = ref(1)
const pageSize = ref(20)
const total = ref(0)

onMounted(() => {
  fetchNews()
})

async function fetchNews() {
  try {
    const res = await newsApi.list({
      page: currentPage.value,
      pageSize: pageSize.value
    })
    newsList.value = res.data.data?.records || []
    total.value = res.data.data?.total || 0
  } catch (e) {
    console.error(e)
  }
}

function goToNews(newsId: number) {
  router.push(`/news/${newsId}`)
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
.news-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.news-card {
  display: flex;
  gap: 18px;
  padding: 18px;
  background: #ffffff;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.2s;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);

  &:hover {
    box-shadow: 0 3px 10px rgba(0, 0, 0, 0.1);
  }

  .news-image {
    width: 200px;
    height: 130px;
    border-radius: 8px;
    overflow: hidden;
    flex-shrink: 0;

    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }
  }

  .news-content {
    flex: 1;
    min-width: 0;

    .news-meta {
      display: flex;
      align-items: center;
      gap: 12px;
      margin-bottom: 8px;

      .news-category {
        font-size: 12px;
        padding: 2px 8px;
        border-radius: 4px;
        background: rgba(26, 86, 219, 0.1);
        color: #1a56db;
      }

      .news-date {
        font-size: 12px;
        color: #a3a3a3;
      }
    }

    h3 {
      margin: 0 0 8px;
      font-size: 16px;
      font-weight: 600;
      color: #262626;
      line-height: 1.4;
      display: -webkit-box;
      -webkit-line-clamp: 2;
      -webkit-box-orient: vertical;
      overflow: hidden;
    }

    .news-summary {
      margin: 0;
      font-size: 14px;
      color: #737373;
      line-height: 1.5;
      display: -webkit-box;
      -webkit-line-clamp: 2;
      -webkit-box-orient: vertical;
      overflow: hidden;
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
}

@media (max-width: 600px) {
  .news-card {
    flex-direction: column;

    .news-image {
      width: 100%;
      height: 180px;
    }
  }
}
</style>
