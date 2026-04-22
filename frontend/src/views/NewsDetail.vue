<template>
  <div class="page-container">
    <div class="page-header">
      <el-button text @click="router.push('/news')">
        <el-icon><ArrowLeft /></el-icon> 返回新闻列表
      </el-button>
    </div>

    <div v-if="article" class="article-detail">
      <div class="article-cover" v-if="article.coverImageUrl">
        <img :src="getImageUrl(article.coverImageUrl)" :alt="article.title" />
      </div>

      <div class="article-header">
        <h1>{{ article.title }}</h1>
        <div class="article-meta">
          <span v-if="article.sourceName" class="source-tag">{{ article.sourceName }}</span>
          <span class="meta-item">{{ formatDate(article.publishedAt) }}</span>
          <span class="meta-item">{{ article.viewCount || 0 }} 阅读</span>
        </div>
      </div>

      <div class="article-body">
        <div v-if="article.content" class="article-content">
          <p v-for="(para, idx) in article.content.split('\n\n')" :key="idx">{{ para }}</p>
        </div>
        <div v-else class="article-content">
          <p>{{ article.summary || '暂无详细内容' }}</p>
        </div>

        <div v-if="article.sourceUrl" class="article-source">
          <el-link :href="article.sourceUrl" target="_blank" type="primary">
            阅读原文 →
          </el-link>
        </div>
      </div>
    </div>

    <div v-else class="loading-state">
      <el-skeleton :rows="8" animated />
    </div>

    <div v-if="article" class="comment-section">
      <div class="section-header">
        <h2>评论留言</h2>
        <span class="comment-count">{{ total }} 条评论</span>
      </div>

      <div class="comment-input">
        <el-input
          v-model="newComment"
          type="textarea"
          :rows="3"
          placeholder="发表你的看法..."
          maxlength="1000"
          show-word-limit
        />
        <el-button type="primary" :loading="submitting" :disabled="!newComment.trim()" @click="submitComment">
          发表评论
        </el-button>
      </div>

      <div class="comments-list">
        <div v-for="comment in comments" :key="comment.commentId" class="comment-item">
          <div class="comment-avatar">
            <span>{{ getUserName(comment.userId)?.charAt(0) || '?' }}</span>
          </div>
          <div class="comment-body">
            <div class="comment-header">
              <span class="comment-user">{{ getUserName(comment.userId) }}</span>
              <span class="comment-time">{{ formatTime(comment.createdAt) }}</span>
              <el-button
                v-if="canDelete(comment)"
                type="danger"
                text
                size="small"
                @click="handleDeleteComment(comment.commentId)"
              >
                删除
              </el-button>
            </div>
            <div class="comment-text">{{ comment.content }}</div>
          </div>
        </div>
      </div>

      <div v-if="comments.length === 0" class="no-comments">暂无评论，快来发表第一条吧！</div>

      <div class="pagination-wrapper">
        <el-pagination v-model:current-page="currentPage" :page-size="pageSize" :total="total"
          layout="prev, pager, next" @current-change="fetchComments" />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { ArrowLeft } from '@element-plus/icons-vue'
import { newsApi } from '@/api'
import api from '@/api'
import { useAuthStore } from '@/stores/auth'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const articleId = Number(route.params.id)
const article = ref<any>(null)
const comments = ref<any[]>([])
const newComment = ref('')
const submitting = ref(false)
const currentPage = ref(1)
const pageSize = ref(20)
const total = ref(0)

const userNameMap = ref<Record<number, string>>({})

onMounted(async () => {
  await fetchArticle()
  await fetchComments()
})

async function fetchArticle() {
  try {
    const res = await newsApi.getById(articleId)
    article.value = res.data.data
  } catch (e) {
    console.error(e)
  }
}

async function fetchComments() {
  try {
    const res = await newsApi.getComments(articleId, {
      page: currentPage.value,
      pageSize: pageSize.value
    })
    comments.value = res.data.data?.records || []
    total.value = res.data.data?.total || 0

    const userIds = [...new Set(comments.value.map((c: any) => c.userId))]
    for (const uid of userIds) {
      if (!userNameMap.value[uid]) {
        try {
          const userRes = await api.get(`/auth/user/${uid}`)
          userNameMap.value[uid] = userRes.data.data?.nickname || userRes.data.data?.username || `用户${uid}`
        } catch {
          userNameMap.value[uid] = `用户${uid}`
        }
      }
    }
  } catch (e) {
    console.error(e)
  }
}

function getUserName(userId: number) {
  return userNameMap.value[userId] || `用户${userId}`
}

async function submitComment() {
  if (!newComment.value.trim()) return
  submitting.value = true
  try {
    await newsApi.addComment(articleId, { content: newComment.value.trim() })
    ElMessage.success('评论成功')
    newComment.value = ''
    currentPage.value = 1
    await fetchComments()
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '评论失败')
  } finally {
    submitting.value = false
  }
}

function canDelete(comment: any) {
  const userId = authStore.user?.userId
  const role = authStore.user?.role
  return comment.userId === userId || role === 'SUPER_ADMIN'
}

async function handleDeleteComment(commentId: number) {
  try {
    await ElMessageBox.confirm('确定删除该评论？', '确认', { type: 'warning' })
    await newsApi.deleteComment(commentId)
    ElMessage.success('评论已删除')
    await fetchComments()
  } catch {}
}

function getImageUrl(path: string) {
  if (!path) return ''
  if (path.startsWith('http://') || path.startsWith('https://')) return path
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

function formatTime(time: string) {
  if (!time) return ''
  return new Date(time).toLocaleString('zh-CN', {
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
    hour12: false
  })
}
</script>

<style scoped lang="scss">
.article-detail {
  background: #ffffff;
  border-radius: 12px;
  overflow: hidden;
  margin-bottom: 24px;
}

.article-cover {
  width: 100%;
  max-height: 400px;
  overflow: hidden;

  img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }
}

.article-header {
  padding: 24px 28px 0;

  h1 {
    margin: 0 0 14px;
    font-size: 24px;
    font-weight: 700;
    color: #1a1a1a;
    line-height: 1.4;
  }

  .article-meta {
    display: flex;
    align-items: center;
    gap: 12px;
    font-size: 13px;
    color: #a3a3a3;

    .source-tag {
      background: rgba(26, 86, 219, 0.1);
      color: #1a56db;
      padding: 2px 8px;
      border-radius: 4px;
      font-size: 12px;
    }
  }
}

.article-body {
  padding: 20px 28px 28px;

  .article-content {
    p {
      font-size: 15px;
      line-height: 1.8;
      color: #333;
      margin: 0 0 16px;
    }
  }

  .article-source {
    margin-top: 20px;
    padding-top: 16px;
    border-top: 1px solid #f0f0f0;
  }
}

.loading-state {
  padding: 30px;
  background: #ffffff;
  border-radius: 12px;
  margin-bottom: 24px;
}

.comment-section {
  background: #ffffff;
  border-radius: 12px;
  padding: 24px 28px;

  .section-header {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 20px;

    h2 {
      margin: 0;
      font-size: 18px;
      font-weight: 600;
      color: #262626;
    }

    .comment-count {
      font-size: 13px;
      color: #a3a3a3;
    }
  }
}

.comment-input {
  margin-bottom: 24px;

  .el-textarea {
    margin-bottom: 10px;
  }

  .el-button {
    float: right;
  }
}

.comments-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.comment-item {
  display: flex;
  gap: 12px;

  .comment-avatar {
    width: 36px;
    height: 36px;
    border-radius: 50%;
    background: #f0f4ff;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 14px;
    color: #1a56db;
    flex-shrink: 0;
  }

  .comment-body {
    flex: 1;
    min-width: 0;

    .comment-header {
      display: flex;
      align-items: center;
      gap: 10px;
      margin-bottom: 4px;

      .comment-user {
        font-size: 13px;
        font-weight: 600;
        color: #262626;
      }

      .comment-time {
        font-size: 12px;
        color: #a3a3a3;
      }
    }

    .comment-text {
      font-size: 14px;
      color: #404040;
      line-height: 1.6;
      word-break: break-word;
    }
  }
}

.no-comments {
  text-align: center;
  padding: 30px;
  color: #a3a3a3;
  font-size: 14px;
}

.pagination-wrapper {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}
</style>
