<template>
  <div class="mobile-community">
    <!-- Header -->
    <div class="page-header">
      <h2>社区</h2>
    </div>

    <!-- Post List -->
    <div class="posts-list" v-if="posts.length > 0">
      <div
        v-for="post in posts"
        :key="post.postId"
        class="post-card"
        @click="goToPost(post.postId)"
      >
        <!-- Author -->
        <div class="post-author">
          <img v-if="post.authorAvatar" :src="getImageUrl(post.authorAvatar)" :alt="post.authorNickname" class="author-avatar" />
          <div v-else class="author-avatar author-avatar--placeholder">
            {{ post.authorNickname?.charAt(0) || 'U' }}
          </div>
          <div class="author-info">
            <span class="author-name">{{ post.authorNickname }}</span>
            <span class="post-time">{{ formatTime(post.createdAt) }}</span>
          </div>
        </div>

        <!-- Content -->
        <p class="post-content">{{ post.content }}</p>

        <!-- Images -->
        <div v-if="post.images && post.images.length > 0" class="post-images">
          <img
            v-for="(img, index) in post.images.slice(0, 3)"
            :key="index"
            :src="getImageUrl(img)"
            :alt="'图片' + (index + 1)"
            class="post-image"
          />
        </div>

        <!-- Stats -->
        <div class="post-stats">
          <span class="stat">
            <el-icon><ChatDotRound /></el-icon>
            {{ post.commentCount || 0 }}
          </span>
          <span class="stat" @click.stop="toggleLike(post)" :class="{ liked: post.liked }">
            <el-icon><Star /></el-icon>
            {{ post.likeCount || 0 }}
          </span>
        </div>
      </div>
    </div>
    <div v-else class="empty">
      <ChatDotRound class="empty-icon" />
      <p>暂无帖子</p>
    </div>

    <!-- FAB -->
    <div class="fab" @click="showCreateDialog = true">
      <el-icon><Plus /></el-icon>
    </div>

    <!-- Create Dialog -->
    <el-dialog v-model="showCreateDialog" title="发布帖子" width="95%" :close-on-click-modal="false">
      <el-form :model="postForm" label-width="60px">
        <el-form-item label="内容">
          <el-input
            v-model="postForm.content"
            type="textarea"
            :rows="4"
            placeholder="分享你的足球观点..."
            maxlength="500"
            show-word-limit
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showCreateDialog = false">取消</el-button>
        <el-button type="primary" @click="createPost" :loading="posting">发布</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ChatDotRound, Star, Plus } from '@element-plus/icons-vue'
import { socialApi } from '@/api'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const posts = ref<any[]>([])
const showCreateDialog = ref(false)
const posting = ref(false)
const postForm = ref({ content: '' })

function getImageUrl(url: string) {
  if (!url) return ''
  if (url.startsWith('http://') || url.startsWith('https://')) return url
  if (url.startsWith('/uploads/')) return url
  return '/uploads/' + url.replace(/^\//, '')
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

function goToPost(postId: number) {
  router.push(`/m/community/${postId}`)
}

async function toggleLike(post: any) {
  if (!authStore.isLoggedIn) {
    ElMessage.warning('请先登录')
    router.push('/login')
    return
  }
  // Toggle like locally for now
  post.liked = !post.liked
  post.likeCount = (post.likeCount || 0) + (post.liked ? 1 : -1)
}

async function fetchPosts() {
  try {
    const res = await socialApi.listPosts({ page: 1, pageSize: 20 })
    posts.value = res.data.data?.records || []
  } catch (e) {
    console.error('加载帖子失败', e)
  }
}

async function createPost() {
  if (!postForm.value.content.trim()) {
    ElMessage.warning('请输入内容')
    return
  }

  posting.value = true
  try {
    await socialApi.createPost({ content: postForm.value.content })
    ElMessage.success('发布成功')
    showCreateDialog.value = false
    postForm.value.content = ''
    fetchPosts()
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '发布失败')
  } finally {
    posting.value = false
  }
}

onMounted(() => {
  authStore.initAuth()
  fetchPosts()
})
</script>

<style scoped lang="scss">
.mobile-community {
  padding-bottom: 80px;
}

.page-header {
  position: sticky;
  top: 0;
  background: rgba(10, 10, 15, 0.95);
  padding: 16px;
  z-index: 10;

  h2 {
    margin: 0;
    font-size: 20px;
    font-weight: 700;
    color: #fff;
  }
}

.posts-list {
  padding: 0 16px;
}

.post-card {
  background: rgba(255, 255, 255, 0.03);
  border-radius: 12px;
  padding: 16px;
  margin-bottom: 12px;
  cursor: pointer;
  transition: all 0.2s;

  &:active {
    background: rgba(255, 255, 255, 0.06);
  }
}

.post-author {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 12px;
}

.author-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
  flex-shrink: 0;

  &--placeholder {
    background: linear-gradient(135deg, #7c3aed, #6d28d9);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 16px;
    font-weight: 600;
    color: #fff;
  }
}

.author-info {
  .author-name {
    display: block;
    font-size: 14px;
    font-weight: 600;
    color: #fff;
  }

  .post-time {
    font-size: 11px;
    color: rgba(255, 255, 255, 0.4);
  }
}

.post-content {
  margin: 0 0 12px;
  font-size: 14px;
  color: rgba(255, 255, 255, 0.9);
  line-height: 1.5;
  display: -webkit-box;
  -webkit-line-clamp: 4;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.post-images {
  display: flex;
  gap: 6px;
  margin-bottom: 12px;
  overflow: hidden;
}

.post-image {
  width: 100px;
  height: 100px;
  border-radius: 8px;
  object-fit: cover;
}

.post-stats {
  display: flex;
  gap: 20px;
}

.stat {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 13px;
  color: rgba(255, 255, 255, 0.5);

  &.liked {
    color: #7c3aed;
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

.fab {
  position: fixed;
  bottom: 80px;
  right: 20px;
  width: 56px;
  height: 56px;
  border-radius: 50%;
  background: linear-gradient(135deg, #7c3aed, #6d28d9);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28px;
  cursor: pointer;
  box-shadow: 0 4px 20px rgba(124, 58, 237, 0.4);
  transition: all 0.2s;

  &:active {
    transform: scale(0.9);
  }
}
</style>
