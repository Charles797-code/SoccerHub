<template>
  <div class="page-container">
    <div v-if="profile" class="user-content">
      <div class="user-card">
        <div class="user-avatar-wrapper">
          <div class="user-avatar">
            <img v-if="profile.avatarUrl" :src="getImageUrl(profile.avatarUrl)" />
            <span v-else>{{ profile.nickname?.charAt(0) || 'U' }}</span>
          </div>
        </div>
        <div class="user-info">
          <div class="user-header">
            <h2>{{ profile.nickname }}</h2>
            <span class="role-badge">{{ roleMap[profile.role] || profile.role }}</span>
          </div>
          <p class="username">@{{ profile.username }}</p>
          <div v-if="profile.favoriteClubName" class="favorite-club">
            <img v-if="profile.favoriteClubLogo" :src="getImageUrl(profile.favoriteClubLogo)" class="club-logo" />
            <span>{{ profile.favoriteClubName }}</span>
          </div>
          <p v-if="profile.bio" class="bio">{{ profile.bio }}</p>
          <div class="stats-row">
            <div class="stat-item" @click="showFollowers">
              <span class="stat-value">{{ profile.followerCount || 0 }}</span>
              <span class="stat-label">粉丝</span>
            </div>
            <div class="stat-item" @click="showFollowing">
              <span class="stat-value">{{ profile.followingCount || 0 }}</span>
              <span class="stat-label">关注</span>
            </div>
            <div class="stat-item">
              <span class="stat-value">{{ profile.postCount || 0 }}</span>
              <span class="stat-label">帖子</span>
            </div>
          </div>
          <div v-if="!isSelf" class="action-buttons">
            <el-button :type="profile.isFollowing ? 'default' : 'primary'" @click="toggleFollow">
              {{ profile.isFollowing ? '已关注' : '关注' }}
            </el-button>
          </div>
        </div>
      </div>

      <div class="posts-section">
        <h3>TA的帖子</h3>
        <div class="posts-list">
          <div v-for="post in posts" :key="post.postId" class="post-item">
            <div class="post-header">
              <div class="post-user">
                <div class="user-avatar">
                  <img v-if="post.userAvatar" :src="getImageUrl(post.userAvatar)" />
                  <span v-else>{{ post.userNickname?.charAt(0) }}</span>
                </div>
                <div class="user-info">
                  <span class="user-name">{{ post.userNickname }}</span>
                  <div v-if="post.userFavoriteClubName" class="user-club">
                    <img v-if="post.userFavoriteClubLogo" :src="getImageUrl(post.userFavoriteClubLogo)" class="club-icon" />
                    <span>{{ post.userFavoriteClubName }}</span>
                  </div>
                </div>
              </div>
              <span class="post-time">{{ formatTime(post.createdAt) }}</span>
            </div>
            <div class="post-content">{{ post.content }}</div>
            <div v-if="post.clubName" class="post-club-tag">
              <el-tag size="small">{{ post.clubName }}</el-tag>
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
          <el-empty v-if="posts.length === 0" description="暂无帖子" />
        </div>
      </div>
    </div>
    <el-empty v-else-if="!loading" description="用户不存在" />

    <el-dialog v-model="showFollowersDialog" title="粉丝列表" width="500px">
      <div class="follow-list">
        <div v-for="u in followers" :key="u.userId" class="follow-item" @click="goToUser(u.userId)">
          <div class="follow-avatar">
            <img v-if="u.avatarUrl" :src="getImageUrl(u.avatarUrl)" />
            <span v-else>{{ u.nickname?.charAt(0) || 'U' }}</span>
          </div>
          <div class="follow-info">
            <span class="follow-name">{{ u.nickname }}</span>
            <span v-if="u.favoriteClubName" class="follow-club">{{ u.favoriteClubName }}</span>
          </div>
        </div>
        <el-empty v-if="followers.length === 0" description="暂无粉丝" />
      </div>
    </el-dialog>

    <el-dialog v-model="showFollowingDialog" title="关注列表" width="500px">
      <div class="follow-list">
        <div v-for="u in followingUsers" :key="u.userId" class="follow-item" @click="goToUser(u.userId)">
          <div class="follow-avatar">
            <img v-if="u.avatarUrl" :src="getImageUrl(u.avatarUrl)" />
            <span v-else>{{ u.nickname?.charAt(0) || 'U' }}</span>
          </div>
          <div class="follow-info">
            <span class="follow-name">{{ u.nickname }}</span>
            <span v-if="u.favoriteClubName" class="follow-club">{{ u.favoriteClubName }}</span>
          </div>
        </div>
        <el-empty v-if="followingUsers.length === 0" description="暂无关注" />
      </div>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useAuthStore } from '@/stores/auth'
import api from '@/api'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const profile = ref<any>(null)
const posts = ref<any[]>([])
const loading = ref(true)

const showFollowersDialog = ref(false)
const showFollowingDialog = ref(false)
const followers = ref<any[]>([])
const followingUsers = ref<any[]>([])

const userId = computed(() => Number(route.params.id))
const isSelf = computed(() => authStore.user?.userId === userId.value)

const roleMap: Record<string, string> = {
  SUPER_ADMIN: '超级管理员',
  CLUB_ADMIN: '俱乐部管理员',
  FAN: '球迷'
}

onMounted(() => {
  loadProfile()
})

watch(() => route.params.id, () => {
  loadProfile()
})

async function loadProfile() {
  try {
    loading.value = true
    const res = await api.get(`/social/user/${userId.value}`)
    profile.value = res.data
    await loadPosts()
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
}

async function loadPosts() {
  try {
    const res = await api.get(`/social/posts/user/${userId.value}`, { params: { page: 1, pageSize: 20 } })
    posts.value = res.data.data?.records || []
  } catch (e) {
    console.error(e)
  }
}

async function toggleFollow() {
  try {
    const res = await api.post(`/social/follow/${userId.value}`)
    const isFollowing = res.data.data?.isFollowing
    profile.value.isFollowing = isFollowing
    profile.value.followerCount += isFollowing ? 1 : -1
    ElMessage.success(isFollowing ? '关注成功' : '已取消关注')
  } catch (e) {
    console.error(e)
  }
}

async function toggleLike(post: any) {
  try {
    const res = await api.post(`/social/posts/${post.postId}/like`)
    const isLiked = res.data.data?.isLiked
    post.isLiked = isLiked
    post.likeCount += isLiked ? 1 : -1
  } catch (e) {
    console.error(e)
  }
}

async function toggleFavorite(post: any) {
  try {
    const res = await api.post(`/social/posts/${post.postId}/favorite`)
    const isFavorited = res.data.data?.isFavorited
    post.isFavorited = isFavorited
    post.favoriteCount += isFavorited ? 1 : -1
    ElMessage.success(isFavorited ? '已收藏' : '已取消收藏')
  } catch (e) {
    console.error(e)
  }
}

async function showFollowers() {
  try {
    const res = await api.get(`/social/followers/${userId.value}`, { params: { page: 1, pageSize: 50 } })
    followers.value = res.data.data?.records || []
    showFollowersDialog.value = true
  } catch (e) {
    console.error(e)
  }
}

async function showFollowing() {
  try {
    const res = await api.get(`/social/following/${userId.value}`, { params: { page: 1, pageSize: 50 } })
    followingUsers.value = res.data.data?.records || []
    showFollowingDialog.value = true
  } catch (e) {
    console.error(e)
  }
}

function goToUser(id: number) {
  showFollowersDialog.value = false
  showFollowingDialog.value = false
  if (id === authStore.user?.userId) {
    router.push('/profile')
  } else {
    router.push(`/user/${id}`)
  }
}

function getImageUrl(url: string) {
  if (!url) return ''
  if (url.startsWith('http://') || url.startsWith('https://')) return url
  if (url.startsWith('/uploads/')) return 'http://localhost:8080' + url
  return 'http://localhost:8080/api' + url
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
@use '@/styles/tokens' as *;

.empty-state {
  text-align: center;
  padding: $space-12 $space-4;
  color: $text-muted;
  font-size: $font-size-base;
  background: $surface-card;
  border: 1px solid $border-subtle;
  border-radius: $radius-xl;
}
</style>
