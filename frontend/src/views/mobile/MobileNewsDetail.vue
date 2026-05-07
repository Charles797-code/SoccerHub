<template>
  <div class="mobile-news-detail">
    <!-- Back Button -->
    <div class="back-bar">
      <button class="back-btn" @click="router.back()">
        <el-icon><ArrowLeft /></el-icon>
      </button>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="loading-state">
      <el-skeleton :rows="8" animated />
    </div>

    <!-- Article Content -->
    <article v-else-if="article" class="article">
      <!-- Cover Image -->
      <div v-if="article.coverImageUrl" class="cover-image">
        <img :src="getImageUrl(article.coverImageUrl)" :alt="article.title" />
      </div>

      <!-- Header -->
      <header class="article-header">
        <h1 class="article-title">{{ article.title }}</h1>
        <div class="article-meta">
          <span v-if="article.sourceName" class="source-tag">{{ article.sourceName }}</span>
          <span class="meta-item">{{ formatDate(article.publishedAt) }}</span>
          <span class="meta-item">{{ article.viewCount || 0 }} 阅读</span>
        </div>
      </header>

      <!-- Content -->
      <div class="article-content" v-html="formattedContent"></div>

      <!-- Share -->
      <div class="share-section">
        <button class="share-btn" @click="handleShare">
          <el-icon><Share /></el-icon>
          分享文章
        </button>
      </div>
    </article>

    <!-- Not Found -->
    <div v-else class="not-found">
      <el-icon class="not-found-icon"><Document /></el-icon>
      <p>文章不存在或已被删除</p>
      <el-button type="primary" @click="router.push('/m/news')">返回资讯</el-button>
    </div>

    <!-- Comments Section -->
    <section class="comments-section" v-if="article">
      <div class="section-header">
        <h2>评论 <span class="comment-count">({{ comments.length }})</span></h2>
      </div>

      <!-- Comment Input -->
      <div class="comment-input-wrap">
        <div class="user-avatar" v-if="user">
          <img v-if="user.avatarUrl" :src="getImageUrl(user.avatarUrl)" :alt="user.nickname" />
          <span v-else>{{ user.nickname?.charAt(0) || 'U' }}</span>
        </div>
        <div v-else class="user-avatar user-avatar--guest">U</div>
        <div class="input-row">
          <input
            v-model="commentText"
            type="text"
            placeholder="写下你的评论..."
            class="comment-input"
            @keyup.enter="submitComment"
          />
          <button class="send-btn" :disabled="!commentText.trim()" @click="submitComment">
            <el-icon><Promotion /></el-icon>
          </button>
        </div>
      </div>

      <!-- Comments List -->
      <div class="comments-list">
        <div v-for="comment in comments" :key="comment.commentId" class="comment-item">
          <img v-if="comment.userAvatar" :src="getImageUrl(comment.userAvatar)" :alt="comment.userNickname" class="comment-avatar" />
          <div v-else class="comment-avatar comment-avatar--placeholder">{{ comment.userNickname?.charAt(0) || 'U' }}</div>
          <div class="comment-body">
            <div class="comment-header">
              <span class="comment-author">{{ comment.userNickname }}</span>
              <span class="comment-time">{{ formatTime(comment.createdAt) }}</span>
            </div>
            <p class="comment-content">{{ comment.content }}</p>
            <button v-if="canDeleteComment(comment)" class="delete-btn" @click="deleteComment(comment.commentId)">
              删除
            </button>
          </div>
        </div>
      </div>

      <div v-if="comments.length === 0 && !loadingComments" class="no-comments">
        <el-icon><ChatDotRound /></el-icon>
        <p>暂无评论，来说点什么吧</p>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ArrowLeft, Document, Share, Promotion, ChatDotRound } from '@element-plus/icons-vue'
import { newsApi } from '@/api'
import { useAuthStore } from '@/stores/auth'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const article = ref<any>(null)
const loading = ref(true)
const loadingComments = ref(true)
const commentText = ref('')
const comments = ref<any[]>([])

const user = computed(() => authStore.user)

const formattedContent = computed(() => {
  if (!article.value?.content) return ''
  return article.value.content.replace(/\n/g, '<br>')
})

function getImageUrl(url: string) {
  if (!url) return ''
  if (url.startsWith('http://') || url.startsWith('https://')) return url
  if (url.startsWith('/uploads/')) return url
  return '/uploads/' + url.replace(/^\//, '')
}

function formatDate(time: string) {
  if (!time) return ''
  return new Date(time).toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

function formatTime(time: string) {
  if (!time) return ''
  const now = new Date()
  const date = new Date(time)
  const diff = now.getTime() - date.getTime()
  const minutes = Math.floor(diff / 60000)
  const hours = Math.floor(diff / 3600000)
  const days = Math.floor(diff / 86400000)

  if (minutes < 1) return '刚刚'
  if (minutes < 60) return `${minutes}分钟前`
  if (hours < 24) return `${hours}小时前`
  if (days < 7) return `${days}天前`
  return date.toLocaleDateString('zh-CN', { month: 'short', day: 'numeric' })
}

function canDeleteComment(comment: any) {
  if (!user.value) return false
  return user.value.role === 'SUPER_ADMIN' || comment.userId === user.value.userId
}

async function fetchArticle() {
  loading.value = true
  try {
    const res = await newsApi.getById(Number(route.params.id))
    article.value = res.data.data
  } catch (e) {
    console.error('加载文章失败', e)
  } finally {
    loading.value = false
  }
}

async function fetchComments() {
  loadingComments.value = true
  try {
    const res = await newsApi.getComments(Number(route.params.id), { page: 1, pageSize: 50 })
    comments.value = res.data.data?.records || []
  } catch (e) {
    console.error('加载评论失败', e)
  } finally {
    loadingComments.value = false
  }
}

async function submitComment() {
  if (!commentText.value.trim()) return

  if (!authStore.isLoggedIn) {
    ElMessage.warning('请先登录')
    router.push('/login')
    return
  }

  try {
    await newsApi.addComment(Number(route.params.id), { content: commentText.value.trim() })
    ElMessage.success('评论成功')
    commentText.value = ''
    fetchComments()
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '评论失败')
  }
}

async function deleteComment(commentId: number) {
  try {
    await newsApi.deleteComment(commentId)
    ElMessage.success('删除成功')
    comments.value = comments.value.filter(c => c.commentId !== commentId)
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '删除失败')
  }
}

function handleShare() {
  if (navigator.share) {
    navigator.share({
      title: article.value?.title,
      text: article.value?.summary,
      url: window.location.href
    })
  } else {
    navigator.clipboard.writeText(window.location.href)
    ElMessage.success('链接已复制到剪贴板')
  }
}

onMounted(() => {
  authStore.initAuth()
  fetchArticle()
  fetchComments()
})
</script>

<style scoped lang="scss">
@use '@/styles/tokens' as *;

.mobile-news-detail {
  min-height: 100vh;
  background: $surface-dark;
}

.back-bar {
  position: sticky;
  top: 0;
  z-index: 10;
  background: rgba(10, 10, 15, 0.95);
  backdrop-filter: blur(10px);
  padding: 12px 16px;
}

.back-btn {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.06);
  border: none;
  color: rgba(255, 255, 255, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s;

  &:active {
    background: rgba(255, 255, 255, 0.1);
    transform: scale(0.95);
  }
}

.loading-state {
  padding: 20px 16px;
}

.article {
  padding-bottom: 40px;
}

.cover-image {
  width: 100%;
  max-height: 300px;
  overflow: hidden;

  img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }
}

.article-header {
  padding: 20px 16px;
}

.article-title {
  margin: 0 0 16px;
  font-size: 22px;
  font-weight: 700;
  color: #fff;
  line-height: 1.4;
}

.article-meta {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}

.source-tag {
  padding: 2px 10px;
  background: rgba($purple-primary, 0.2);
  border: 1px solid rgba($purple-primary, 0.3);
  border-radius: 20px;
  font-size: 12px;
  color: $purple-light;
  font-weight: 500;
}

.meta-item {
  font-size: 12px;
  color: $text-muted;
}

.article-content {
  padding: 0 16px;
  font-size: 15px;
  line-height: 1.8;
  color: rgba(255, 255, 255, 0.9);

  :deep(p) {
    margin: 0 0 16px;
  }

  :deep(img) {
    max-width: 100%;
    border-radius: 8px;
    margin: 16px 0;
  }
}

.share-section {
  padding: 24px 16px;
  border-top: 1px solid rgba(255, 255, 255, 0.06);
  margin-top: 24px;
}

.share-btn {
  width: 100%;
  padding: 14px;
  background: rgba($purple-primary, 0.1);
  border: 1px solid rgba($purple-primary, 0.3);
  border-radius: 12px;
  color: $purple-light;
  font-size: 14px;
  font-weight: 500;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  cursor: pointer;
  transition: all 0.2s;

  &:active {
    background: rgba($purple-primary, 0.15);
    transform: scale(0.98);
  }
}

.not-found {
  text-align: center;
  padding: 80px 20px;
  color: $text-muted;

  .not-found-icon {
    font-size: 64px;
    margin-bottom: 16px;
    opacity: 0.5;
  }

  p {
    margin: 0 0 20px;
    font-size: 16px;
  }
}

.comments-section {
  padding: 20px 16px;
  background: rgba(0, 0, 0, 0.2);
}

.section-header {
  margin-bottom: 16px;

  h2 {
    margin: 0;
    font-size: 16px;
    font-weight: 600;
    color: #fff;
  }

  .comment-count {
    color: $text-muted;
    font-weight: 400;
  }
}

.comment-input-wrap {
  display: flex;
  gap: 12px;
  margin-bottom: 20px;
}

.user-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: linear-gradient(135deg, $purple-primary, $gold-dark);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: 600;
  color: #fff;
  flex-shrink: 0;
  overflow: hidden;

  img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }

  &--guest {
    background: rgba(255, 255, 255, 0.1);
  }
}

.input-row {
  flex: 1;
  display: flex;
  gap: 8px;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 20px;
  padding: 4px 4px 4px 16px;
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.comment-input {
  flex: 1;
  background: none;
  border: none;
  outline: none;
  font-size: 14px;
  color: #fff;
  min-width: 0;

  &::placeholder {
    color: $text-muted;
  }
}

.send-btn {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: $purple-primary;
  border: none;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s;
  flex-shrink: 0;

  &:disabled {
    background: rgba(255, 255, 255, 0.1);
    color: $text-muted;
    cursor: not-allowed;
  }

  &:not(:disabled):active {
    transform: scale(0.9);
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
}

.comment-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  object-fit: cover;
  flex-shrink: 0;

  &--placeholder {
    background: rgba($purple-primary, 0.2);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 14px;
    font-weight: 600;
    color: $purple-light;
  }
}

.comment-body {
  flex: 1;
  min-width: 0;
}

.comment-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 4px;
}

.comment-author {
  font-size: 13px;
  font-weight: 600;
  color: #fff;
}

.comment-time {
  font-size: 11px;
  color: $text-muted;
}

.comment-content {
  margin: 0;
  font-size: 14px;
  color: rgba(255, 255, 255, 0.85);
  line-height: 1.5;
}

.delete-btn {
  background: none;
  border: none;
  color: $danger-light;
  font-size: 12px;
  cursor: pointer;
  padding: 4px 0;
  margin-top: 4px;

  &:hover {
    text-decoration: underline;
  }
}

.no-comments {
  text-align: center;
  padding: 32px;
  color: $text-muted;

  .el-icon {
    font-size: 40px;
    margin-bottom: 12px;
    opacity: 0.4;
  }

  p {
    margin: 0;
    font-size: 14px;
  }
}
</style>
