<template>
  <div class="page-container">
    <div class="page-header">
      <h1>社区</h1>
    </div>

    <div class="community-content">
      <div class="sidebar">
        <div class="circle-list">
          <h3>圈子</h3>
          <div class="circle-item" :class="{ active: currentCircleId === null }" @click="selectCircle(null)">
            <el-icon><HomeFilled /></el-icon>
            <span>主社区</span>
          </div>
          <div v-for="circle in circles" :key="circle.circleId" class="circle-item" :class="{ active: currentCircleId === circle.circleId }" @click="selectCircle(circle.circleId)">
            <img v-if="circle.logoUrl" :src="getImageUrl(circle.logoUrl)" class="circle-logo" />
            <div v-else class="circle-logo-placeholder">{{ circle.name?.charAt(0) }}</div>
            <div class="circle-info">
              <span class="circle-name">{{ circle.name }}</span>
              <span class="circle-members">{{ circle.memberCount || 0 }} 成员</span>
            </div>
          </div>
        </div>
      </div>

      <div class="main-area">
        <div v-if="currentCircle" class="circle-header">
          <img v-if="currentCircle.logoUrl" :src="getImageUrl(currentCircle.logoUrl)" class="circle-avatar" />
          <div v-else class="circle-avatar-placeholder">{{ currentCircle.name?.charAt(0) }}</div>
          <div class="circle-details">
            <h2>{{ currentCircle.name }}</h2>
            <p>{{ currentCircle.description }}</p>
            <div class="circle-stats">
              <span>{{ currentCircle.memberCount || 0 }} 成员</span>
              <span>{{ currentCircle.postCount || 0 }} 帖子</span>
            </div>
          </div>
          <el-button v-if="currentCircleId !== null" :type="currentCircle.isMember ? 'default' : 'primary'" @click="joinCircle">
            {{ currentCircle.isMember ? '已加入' : '加入圈子' }}
          </el-button>
        </div>

        <div class="create-post-card">
          <el-input v-model="newPostContent" type="textarea" :rows="3" placeholder="分享你的想法..." maxlength="500" show-word-limit />
          <div class="post-actions">
            <el-select v-model="newPostClubId" placeholder="关联俱乐部(可选)" clearable filterable size="small" style="width:200px">
              <el-option v-for="club in clubs" :key="club.clubId" :label="club.name" :value="club.clubId" />
            </el-select>
            <el-button type="primary" @click="createPost" :loading="postLoading" :disabled="!newPostContent.trim()">发布</el-button>
          </div>
        </div>

        <el-tabs v-model="activeTab" class="posts-tabs">
          <el-tab-pane label="最新" name="latest"></el-tab-pane>
          <el-tab-pane label="精华" name="essence"></el-tab-pane>
        </el-tabs>

        <div class="posts-list">
          <div v-for="post in posts" :key="post.postId" class="post-card">
            <div class="post-header">
              <div class="post-user" @click="goToUser(post.userId)">
                <div class="user-avatar">
                  <img v-if="post.userAvatar" :src="getImageUrl(post.userAvatar)" />
                  <span v-else>{{ post.userNickname?.charAt(0) }}</span>
                </div>
                <div class="user-info">
                  <div class="user-name-row">
                    <span class="user-name">{{ post.userNickname }}</span>
                    <el-tag v-if="post.isPinned" type="warning" size="small">置顶</el-tag>
                    <el-tag v-if="post.isEssence" type="success" size="small">精华</el-tag>
                  </div>
                  <div v-if="post.userFavoriteClubName" class="user-club">
                    <img v-if="post.userFavoriteClubLogo" :src="getImageUrl(post.userFavoriteClubLogo)" class="club-icon" />
                    <span>{{ post.userFavoriteClubName }}</span>
                  </div>
                </div>
              </div>
              <div class="post-header-right">
                <el-button v-if="post.userId !== currentUserId && !post.isFollowing" type="primary" size="small" @click.stop="toggleFollowUser(post)">关注</el-button>
                <el-button v-if="post.userId !== currentUserId && post.isFollowing" size="small" @click.stop="toggleFollowUser(post)">已关注</el-button>
                <span class="post-time">{{ formatTime(post.createdAt) }}</span>
              </div>
            </div>
            <div class="post-content">{{ post.content }}</div>
            <div v-if="post.imageUrls && post.imageUrls.length > 0" class="post-images">
              <img v-for="(url, idx) in post.imageUrls" :key="idx" :src="getImageUrl(url)" @click="previewImage(url)" />
            </div>
            <div v-if="post.clubName || post.circleName" class="post-tags">
              <el-tag v-if="post.circleName && currentCircleId === null" size="small" type="info">{{ post.circleName }}</el-tag>
              <el-tag v-if="post.clubName" size="small">{{ post.clubName }}</el-tag>
            </div>
            <div class="post-footer">
              <span class="post-stat" :class="{ liked: post.isLiked }" @click="toggleLike(post)">
                <el-icon><Star /></el-icon> {{ post.likeCount }}
              </span>
              <span class="post-stat" :class="{ favorited: post.isFavorited }" @click="toggleFavorite(post)">
                <el-icon><CollectionTag /></el-icon> {{ post.favoriteCount }}
              </span>
            </div>
          </div>
          <el-empty v-if="posts.length === 0 && !loading" description="暂无帖子，快来发布第一条吧！" />
          <div v-if="hasMore" class="load-more">
            <el-button @click="loadMore" :loading="loading">加载更多</el-button>
          </div>
        </div>
      </div>
    </div>

    <el-dialog v-model="previewVisible" width="80%" :show-close="true">
      <img :src="previewUrl" style="width:100%;max-height:80vh;object-fit:contain" />
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch, computed } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { clubApi } from '@/api'
import api from '@/api'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const authStore = useAuthStore()
const currentUserId = computed(() => authStore.user?.userId)
const circles = ref<any[]>([])
const currentCircleId = ref<number | null>(null)
const currentCircle = ref<any>(null)
const posts = ref<any[]>([])
const clubs = ref<any[]>([])
const loading = ref(false)
const hasMore = ref(true)
const currentPage = ref(1)
const pageSize = 20
const activeTab = ref('latest')

const newPostContent = ref('')
const newPostClubId = ref<number | null>(null)
const postLoading = ref(false)

const previewVisible = ref(false)
const previewUrl = ref('')

onMounted(async () => {
  await loadClubs()
  await loadCircles()
  await loadPosts()
})

watch(currentCircleId, () => {
  currentPage.value = 1
  loadPosts()
})

watch(activeTab, () => {
  currentPage.value = 1
  loadPosts()
})

async function loadClubs() {
  try {
    const res = await clubApi.list({ page: 1, pageSize: 100 })
    clubs.value = res.data.data?.records || []
  } catch (e) {
    console.error(e)
  }
}

async function loadCircles() {
  try {
    const res = await api.get('/social/circles')
    const allCircles = res.data || []
    circles.value = allCircles.filter((c: any) => c.clubId !== null)
    const mainCircle = allCircles.find((c: any) => c.clubId === null)
    if (mainCircle) {
      currentCircle.value = mainCircle
    }
  } catch (e) {
    console.error(e)
  }
}

async function loadPosts() {
  try {
    loading.value = true
    let res
    if (activeTab.value === 'essence') {
      res = await api.get('/social/posts/essence', { params: { page: currentPage.value, pageSize } })
    } else if (currentCircleId.value) {
      res = await api.get(`/social/circles/${currentCircleId.value}/posts`, { params: { page: currentPage.value, pageSize } })
    } else {
      res = await api.get('/social/posts', { params: { page: currentPage.value, pageSize } })
    }
    const newPosts = res.data.records || []
    posts.value = currentPage.value === 1 ? newPosts : [...posts.value, ...newPosts]
    hasMore.value = newPosts.length === pageSize
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
}

async function loadMore() {
  currentPage.value++
  await loadPosts()
}

function selectCircle(circleId: number | null) {
  currentCircleId.value = circleId
  if (circleId) {
    const circle = circles.value.find(c => c.circleId === circleId)
    currentCircle.value = circle
  } else {
    loadCircles()
  }
}

async function joinCircle() {
  if (!currentCircleId.value) return
  try {
    const res = await api.post(`/social/circles/${currentCircleId.value}/join`)
    currentCircle.value.isMember = res.data.isMember
    currentCircle.value.memberCount += res.data.isMember ? 1 : -1
    ElMessage.success(res.data.isMember ? '已加入圈子' : '已退出圈子')
  } catch (e) {
    console.error(e)
  }
}

async function createPost() {
  if (!newPostContent.value.trim()) return
  try {
    postLoading.value = true
    await api.post('/social/posts', {
      content: newPostContent.value,
      clubId: newPostClubId.value,
      circleId: currentCircleId.value
    })
    ElMessage.success('发布成功')
    newPostContent.value = ''
    newPostClubId.value = null
    currentPage.value = 1
    await loadPosts()
    if (currentCircle.value) {
      currentCircle.value.postCount = (currentCircle.value.postCount || 0) + 1
    }
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '发布失败')
  } finally {
    postLoading.value = false
  }
}

async function toggleLike(post: any) {
  try {
    const res = await api.post(`/social/posts/${post.postId}/like`)
    post.isLiked = res.data.isLiked
    post.likeCount += res.data.isLiked ? 1 : -1
  } catch (e) {
    console.error(e)
  }
}

async function toggleFavorite(post: any) {
  try {
    const res = await api.post(`/social/posts/${post.postId}/favorite`)
    post.isFavorited = res.data.isFavorited
    post.favoriteCount += res.data.isFavorited ? 1 : -1
    ElMessage.success(res.data.isFavorited ? '已收藏' : '已取消收藏')
  } catch (e) {
    console.error(e)
  }
}

async function toggleFollowUser(post: any) {
  try {
    const res = await api.post(`/social/follow/${post.userId}`)
    post.isFollowing = res.data.isFollowing
    ElMessage.success(res.data.isFollowing ? '关注成功' : '已取消关注')
  } catch (e) {
    console.error(e)
  }
}

function goToUser(userId: number) {
  router.push(`/user/${userId}`)
}

function getImageUrl(url: string) {
  if (!url) return ''
  if (url.startsWith('http://') || url.startsWith('https://')) return url
  return '/api' + url
}

function previewImage(url: string) {
  previewUrl.value = getImageUrl(url)
  previewVisible.value = true
}

function formatTime(time: string) {
  if (!time) return ''
  const d = new Date(time)
  const now = new Date()
  const diff = now.getTime() - d.getTime()
  if (diff < 60000) return '刚刚'
  if (diff < 3600000) return `${Math.floor(diff / 60000)}分钟前`
  if (diff < 86400000) return `${Math.floor(diff / 3600000)}小时前`
  if (diff < 604800000) return `${Math.floor(diff / 86400000)}天前`
  return d.toLocaleDateString('zh-CN')
}
</script>

<style scoped lang="scss">
.community-content {
  display: flex;
  gap: 20px;
}

.sidebar {
  width: 280px;
  flex-shrink: 0;
}

.circle-list {
  background: #ffffff;
  border-radius: 12px;
  padding: 16px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);

  h3 {
    margin: 0 0 12px;
    font-size: 14px;
    font-weight: 600;
    color: #262626;
  }
}

.circle-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s;
  margin-bottom: 4px;

  &:hover {
    background: #f5f5f5;
  }

  &.active {
    background: rgba(26, 86, 219, 0.1);
  }

  .circle-logo, .circle-logo-placeholder {
    width: 40px;
    height: 40px;
    border-radius: 8px;
    object-fit: contain;
    background: rgba(26, 86, 219, 0.1);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 16px;
    color: #1a56db;
  }

  .circle-info {
    flex: 1;
    min-width: 0;

    .circle-name {
      display: block;
      font-size: 14px;
      font-weight: 500;
      color: #262626;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    .circle-members {
      font-size: 12px;
      color: #a3a3a3;
    }
  }
}

.main-area {
  flex: 1;
  min-width: 0;
}

.circle-header {
  display: flex;
  align-items: center;
  gap: 16px;
  background: #ffffff;
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 16px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);

  .circle-avatar, .circle-avatar-placeholder {
    width: 64px;
    height: 64px;
    border-radius: 12px;
    object-fit: contain;
    background: rgba(26, 86, 219, 0.1);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 28px;
    color: #1a56db;
  }

  .circle-details {
    flex: 1;

    h2 {
      margin: 0 0 4px;
      font-size: 18px;
      font-weight: 600;
      color: #262626;
    }

    p {
      margin: 0 0 8px;
      font-size: 13px;
      color: #737373;
    }

    .circle-stats {
      font-size: 12px;
      color: #a3a3a3;

      span {
        margin-right: 16px;
      }
    }
  }
}

.create-post-card {
  background: #ffffff;
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 16px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);

  .post-actions {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: 12px;
  }
}

.posts-tabs {
  background: #ffffff;
  border-radius: 12px;
  padding: 0 16px;
  margin-bottom: 16px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);
}

.posts-list {
  .post-card {
    background: #ffffff;
    border-radius: 12px;
    padding: 20px;
    margin-bottom: 16px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);

    .post-header {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      margin-bottom: 12px;

      .post-user {
        display: flex;
        align-items: center;
        gap: 12px;
        cursor: pointer;

        .user-avatar {
          width: 48px;
          height: 48px;
          border-radius: 50%;
          background: rgba(26, 86, 219, 0.1);
          display: flex;
          align-items: center;
          justify-content: center;
          font-size: 20px;
          color: #1a56db;
          overflow: hidden;

          img {
            width: 100%;
            height: 100%;
            object-fit: cover;
          }
        }

        .user-info {
          .user-name-row {
            display: flex;
            align-items: center;
            gap: 8px;
          }

          .user-name {
            font-weight: 600;
            font-size: 16px;
            color: #262626;
          }

          .user-club {
            display: flex;
            align-items: center;
            gap: 4px;
            font-size: 12px;
            color: #a3a3a3;
            margin-top: 2px;

            .club-icon {
              width: 14px;
              height: 14px;
              object-fit: contain;
            }
          }
        }
      }

      .post-time {
        font-size: 12px;
        color: #a3a3a3;
      }

      .post-header-right {
        display: flex;
        align-items: center;
        gap: 12px;
      }
    }

    .post-content {
      font-size: 15px;
      line-height: 1.7;
      color: #262626;
      margin-bottom: 12px;
    }

    .post-images {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 8px;
      margin-bottom: 12px;

      img {
        width: 100%;
        aspect-ratio: 1;
        object-fit: cover;
        border-radius: 8px;
        cursor: pointer;
        transition: transform 0.2s;

        &:hover {
          transform: scale(1.02);
        }
      }
    }

    .post-tags {
      display: flex;
      gap: 8px;
      margin-bottom: 12px;
    }

    .post-footer {
      display: flex;
      gap: 20px;
      padding-top: 12px;
      border-top: 1px solid #f0f0f0;

      .post-stat {
        display: flex;
        align-items: center;
        gap: 6px;
        font-size: 14px;
        color: #a3a3a3;
        cursor: pointer;
        transition: color 0.2s;

        &:hover {
          color: #1a56db;
        }

        &.liked, &.favorited {
          color: #f59e0b;
        }
      }
    }
  }
}

.load-more {
  text-align: center;
  padding: 20px;
}
</style>
