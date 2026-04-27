<template>
  <div class="page-container">
    <div class="page-header">
      <h1>个人中心</h1>
    </div>

    <div v-if="user" class="profile-content">
      <div class="profile-card">
        <div class="profile-avatar-wrapper">
          <div class="profile-avatar" @click="showAvatarDialog = true">
            <img v-if="user.avatarUrl" :src="getImageUrl(user.avatarUrl)" alt="avatar" />
            <span v-else>{{ user.nickname?.charAt(0) || user.username?.charAt(0) }}</span>
          </div>
          <div class="avatar-edit" @click="showAvatarDialog = true">
            <el-icon><Camera /></el-icon>
          </div>
        </div>
        <div class="profile-info">
          <div class="profile-header">
            <h2>{{ user.nickname || user.username }}</h2>
            <span class="role-badge">{{ roleMap[user.role] || user.role }}</span>
          </div>
          <p class="username">@{{ user.username }}</p>
          <div v-if="user.favoriteClubName" class="favorite-club">
            <img v-if="user.favoriteClubLogo" :src="getImageUrl(user.favoriteClubLogo)" class="club-logo" />
            <span>{{ user.favoriteClubName }}</span>
          </div>
          <p v-if="user.bio" class="bio">{{ user.bio }}</p>
          <div class="stats-row">
            <div class="stat-item" @click="showFollowers">
              <span class="stat-value">{{ profile?.followerCount || 0 }}</span>
              <span class="stat-label">粉丝</span>
            </div>
            <div class="stat-item" @click="showFollowing">
              <span class="stat-value">{{ profile?.followingCount || 0 }}</span>
              <span class="stat-label">关注</span>
            </div>
            <div class="stat-item" @click="showMyPosts">
              <span class="stat-value">{{ profile?.postCount || 0 }}</span>
              <span class="stat-label">帖子</span>
            </div>
          </div>
        </div>
      </div>

      <el-tabs v-model="activeTab" class="profile-tabs">
        <el-tab-pane label="编辑资料" name="edit">
          <div class="profile-section">
            <h3>基本信息</h3>
            <el-form label-width="80px">
              <el-form-item label="昵称">
                <el-input v-model="editForm.nickname" placeholder="输入昵称" style="max-width: 400px;" />
              </el-form-item>
              <el-form-item label="个人简介">
                <el-input v-model="editForm.bio" type="textarea" :rows="3" placeholder="介绍一下自己..." style="max-width: 400px;" maxlength="200" show-word-limit />
              </el-form-item>
              <el-form-item label="主队">
                <el-select v-model="editForm.favoriteClubId" placeholder="选择你的主队" clearable filterable style="max-width: 400px;">
                  <el-option v-for="club in clubs" :key="club.clubId" :label="club.name" :value="club.clubId">
                    <div style="display:flex;align-items:center;gap:8px">
                      <img v-if="club.logoUrl" :src="getImageUrl(club.logoUrl)" style="width:20px;height:20px;object-fit:contain" />
                      <span>{{ club.name }}</span>
                    </div>
                  </el-option>
                </el-select>
              </el-form-item>
              <el-form-item>
                <el-button type="primary" @click="saveProfile" :loading="saveLoading">保存修改</el-button>
              </el-form-item>
            </el-form>
          </div>

          <div class="profile-section">
            <h3>修改密码</h3>
            <el-form label-width="80px">
              <el-form-item label="当前密码">
                <el-input v-model="passwordForm.oldPassword" type="password" placeholder="当前密码" show-password style="max-width: 400px;" />
              </el-form-item>
              <el-form-item label="新密码">
                <el-input v-model="passwordForm.newPassword" type="password" placeholder="新密码" show-password style="max-width: 400px;" />
              </el-form-item>
              <el-form-item>
                <el-button type="primary" @click="updatePassword" :loading="passwordLoading">修改密码</el-button>
              </el-form-item>
            </el-form>
          </div>
        </el-tab-pane>

        <el-tab-pane label="我的帖子" name="posts">
          <div class="posts-section">
            <div class="create-post">
              <el-input v-model="newPostContent" type="textarea" :rows="3" placeholder="分享你的想法..." maxlength="500" show-word-limit />
              <div class="post-actions">
                <el-select v-model="newPostClubId" placeholder="关联俱乐部(可选)" clearable filterable size="small" style="width:200px">
                  <el-option v-for="club in clubs" :key="club.clubId" :label="club.name" :value="club.clubId" />
                </el-select>
                <el-button type="primary" @click="createPost" :loading="postLoading" :disabled="!newPostContent.trim()">发布</el-button>
              </div>
            </div>
            <div class="posts-list">
              <div v-for="post in myPosts" :key="post.postId" class="post-item">
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
                  <span class="post-stat"><el-icon><Star /></el-icon> {{ post.likeCount }}</span>
                  <span class="post-stat"><el-icon><CollectionTag /></el-icon> {{ post.favoriteCount }}</span>
                  <el-button type="danger" size="small" text @click="deletePost(post.postId)">删除</el-button>
                </div>
              </div>
              <el-empty v-if="myPosts.length === 0" description="暂无帖子" />
            </div>
          </div>
        </el-tab-pane>

        <el-tab-pane label="我的收藏" name="favorites">
          <div class="posts-list">
            <div v-for="post in favoritePosts" :key="post.postId" class="post-item">
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
              <div class="post-footer">
                <span class="post-stat" :class="{ liked: post.isLiked }" @click="toggleLike(post)">
                  <el-icon><Star /></el-icon> {{ post.likeCount }}
                </span>
                <span class="post-stat favorited" @click="toggleFavorite(post)">
                  <el-icon><CollectionTag /></el-icon> {{ post.favoriteCount }}
                </span>
              </div>
            </div>
            <el-empty v-if="favoritePosts.length === 0" description="暂无收藏" />
          </div>
        </el-tab-pane>
      </el-tabs>
    </div>

    <el-dialog v-model="showAvatarDialog" title="修改头像" width="400px">
      <el-upload
        class="avatar-uploader"
        :action="uploadUrl"
        :headers="uploadHeaders"
        :show-file-list="false"
        :on-success="handleAvatarSuccess"
        accept="image/*"
      >
        <img v-if="tempAvatar" :src="tempAvatar" class="avatar-preview" />
        <el-icon v-else class="avatar-uploader-icon"><Plus /></el-icon>
      </el-upload>
      <template #footer>
        <el-button @click="showAvatarDialog = false">取消</el-button>
        <el-button type="primary" @click="saveAvatar" :loading="avatarLoading">保存</el-button>
      </template>
    </el-dialog>

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
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useAuthStore } from '@/stores/auth'
import { authApi, clubApi } from '@/api'
import api from '@/api'

const router = useRouter()
const authStore = useAuthStore()
const user = ref<any>(null)
const profile = ref<any>(null)
const clubs = ref<any[]>([])
const activeTab = ref('edit')

const editForm = ref({ nickname: '', bio: '', favoriteClubId: null as number | null })
const passwordForm = ref({ oldPassword: '', newPassword: '' })
const saveLoading = ref(false)
const passwordLoading = ref(false)

const showAvatarDialog = ref(false)
const tempAvatar = ref('')
const avatarLoading = ref(false)

const newPostContent = ref('')
const newPostClubId = ref<number | null>(null)
const postLoading = ref(false)
const myPosts = ref<any[]>([])
const favoritePosts = ref<any[]>([])

const showFollowersDialog = ref(false)
const showFollowingDialog = ref(false)
const followers = ref<any[]>([])
const followingUsers = ref<any[]>([])

const roleMap: Record<string, string> = {
  SUPER_ADMIN: '超级管理员',
  CLUB_ADMIN: '俱乐部管理员',
  FAN: '球迷'
}

const uploadUrl = '/api/upload/image'
const uploadHeaders = computed(() => ({
  Authorization: `Bearer ${localStorage.getItem('token')}`
}))

onMounted(async () => {
  const profileLoaded = await loadProfile()
  await loadClubs()
  if (profileLoaded) {
    await loadMyPosts()
    await loadFavoritePosts()
  }
})

async function loadProfile() {
  try {
    const res = await authApi.getProfile()
    user.value = res.data.data
    editForm.value = {
      nickname: user.value.nickname || '',
      bio: user.value.bio || '',
      favoriteClubId: user.value.favoriteClubId
    }
    const profileRes = await api.get(`/social/user/${user.value.userId}`)
    profile.value = profileRes.data.data
    return true
  } catch (e) {
    console.error(e)
    return false
  }
}

async function loadClubs() {
  try {
    const res = await clubApi.list({ page: 1, pageSize: 100 })
    clubs.value = res.data.data?.records || []
  } catch (e) {
    console.error(e)
  }
}

async function loadMyPosts() {
  try {
    const res = await api.get(`/social/posts/user/${user.value?.userId}`, { params: { page: 1, pageSize: 20 } })
    myPosts.value = res.data.data?.records || []
  } catch (e) {
    console.error(e)
  }
}

async function loadFavoritePosts() {
  try {
    const res = await api.get('/social/favorites', { params: { page: 1, pageSize: 20 } })
    favoritePosts.value = res.data.data?.records || []
  } catch (e) {
    console.error(e)
  }
}

async function saveProfile() {
  try {
    saveLoading.value = true
    await api.put('/social/profile', editForm.value)
    ElMessage.success('保存成功')
    await loadProfile()
    // Sync updated profile to auth store so the header nickname reflects the change immediately
    if (authStore.user) {
      authStore.user.nickname = user.value.nickname
      authStore.user.bio = user.value.bio
      authStore.user.avatarUrl = user.value.avatarUrl
      authStore.user.favoriteClubId = user.value.favoriteClubId
      localStorage.setItem('user', JSON.stringify(authStore.user))
    }
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '保存失败')
  } finally {
    saveLoading.value = false
  }
}

async function updatePassword() {
  if (!passwordForm.value.oldPassword || !passwordForm.value.newPassword) {
    ElMessage.warning('请填写完整密码信息')
    return
  }
  try {
    passwordLoading.value = true
    await authApi.updateProfile({ oldPassword: passwordForm.value.oldPassword, newPassword: passwordForm.value.newPassword })
    ElMessage.success('密码修改成功')
    passwordForm.value = { oldPassword: '', newPassword: '' }
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '修改失败')
  } finally {
    passwordLoading.value = false
  }
}

function handleAvatarSuccess(res: any) {
  if (res.data) {
    const url = typeof res.data === 'string' ? res.data : res.data.url
    if (url) {
      tempAvatar.value = getImageUrl(url)
    }
  }
}

async function saveAvatar() {
  if (!tempAvatar.value) {
    ElMessage.warning('请先选择图片')
    return
  }
  try {
    avatarLoading.value = true
    await authApi.updateProfile({ avatarUrl: tempAvatar.value })
    user.value.avatarUrl = tempAvatar.value
    if (authStore.user) {
      authStore.user.avatarUrl = tempAvatar.value
      localStorage.setItem('user', JSON.stringify(authStore.user))
    }
    showAvatarDialog.value = false
    tempAvatar.value = ''
    ElMessage.success('头像更新成功')
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '保存失败')
  } finally {
    avatarLoading.value = false
  }
}

async function createPost() {
  if (!newPostContent.value.trim()) return
  try {
    postLoading.value = true
    await api.post('/social/posts', {
      content: newPostContent.value,
      clubId: newPostClubId.value
    })
    ElMessage.success('发布成功')
    newPostContent.value = ''
    newPostClubId.value = null
    await loadMyPosts()
    await loadProfile()
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '发布失败')
  } finally {
    postLoading.value = false
  }
}

async function deletePost(postId: number) {
  try {
    await api.delete(`/social/posts/${postId}`)
    ElMessage.success('删除成功')
    await loadMyPosts()
    await loadProfile()
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '删除失败')
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
    if (!isFavorited) {
      await loadFavoritePosts()
    }
  } catch (e) {
    console.error(e)
  }
}

async function showFollowers() {
  try {
    const res = await api.get(`/social/followers/${user.value.userId}`, { params: { page: 1, pageSize: 50 } })
    followers.value = res.data.data?.records || []
    showFollowersDialog.value = true
  } catch (e) {
    console.error(e)
  }
}

async function showFollowing() {
  try {
    const res = await api.get(`/social/following/${user.value.userId}`, { params: { page: 1, pageSize: 50 } })
    followingUsers.value = res.data.data?.records || []
    showFollowingDialog.value = true
  } catch (e) {
    console.error(e)
  }
}

function showMyPosts() {
  activeTab.value = 'posts'
}

function goToUser(userId: number) {
  showFollowersDialog.value = false
  showFollowingDialog.value = false
  router.push(`/user/${userId}`)
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

.page-header {
  h1 {
    font-family: $font-display;
    font-size: $font-size-2xl;
    font-weight: $font-weight-bold;
    color: $text-primary;
    letter-spacing: $letter-spacing-tight;
    margin: 0;
  }
  margin-bottom: $space-5;
}
</style>
