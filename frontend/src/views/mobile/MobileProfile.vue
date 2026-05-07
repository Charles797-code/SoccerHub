<template>
  <div class="mobile-profile">
    <!-- User Info -->
    <div class="user-header">
      <div class="avatar-wrap">
        <img v-if="user?.avatarUrl" :src="getImageUrl(user.avatarUrl)" :alt="user.nickname" class="avatar" />
        <div v-else class="avatar avatar--placeholder">
          {{ user?.nickname?.charAt(0) || 'U' }}
        </div>
      </div>
      <h2 class="username">{{ user?.nickname || '用户' }}</h2>
      <p class="user-role">{{ getRoleLabel(user?.role) }}</p>
    </div>

    <!-- Stats -->
    <div class="stats-row">
      <div class="stat-item">
        <span class="stat-value">{{ userStats.points || 0 }}</span>
        <span class="stat-label">积分</span>
      </div>
      <div class="stat-item">
        <span class="stat-value">{{ userStats.predictions || 0 }}</span>
        <span class="stat-label">竞猜</span>
      </div>
      <div class="stat-item">
        <span class="stat-value">{{ userStats.following || 0 }}</span>
        <span class="stat-label">关注</span>
      </div>
    </div>

    <!-- Menu List -->
    <div class="menu-list">
      <div class="menu-item" @click="router.push('/m/predictions')">
        <div class="menu-icon-wrap"><Aim class="menu-icon" /></div>
        <span class="menu-text">我的竞猜</span>
        <el-icon class="menu-arrow"><ArrowRight /></el-icon>
      </div>
      <div class="menu-item" @click="router.push('/m/favorites')">
        <div class="menu-icon-wrap"><Star class="menu-icon" /></div>
        <span class="menu-text">我的收藏</span>
        <el-icon class="menu-arrow"><ArrowRight /></el-icon>
      </div>
      <div class="menu-item" @click="router.push('/m/community')">
        <div class="menu-icon-wrap"><ChatDotRound class="menu-icon" /></div>
        <span class="menu-text">我的帖子</span>
        <el-icon class="menu-arrow"><ArrowRight /></el-icon>
      </div>
      <div class="menu-item" @click="router.push('/m/following')">
        <div class="menu-icon-wrap"><User class="menu-icon" /></div>
        <span class="menu-text">我的关注</span>
        <el-icon class="menu-arrow"><ArrowRight /></el-icon>
      </div>
    </div>

    <div class="menu-divider"></div>

    <div class="menu-list">
      <div class="menu-item" @click="showEditDialog = true">
        <div class="menu-icon-wrap"><Edit class="menu-icon" /></div>
        <span class="menu-text">编辑资料</span>
        <el-icon class="menu-arrow"><ArrowRight /></el-icon>
      </div>
      <div class="menu-item" @click="router.push('/m/settings')">
        <div class="menu-icon-wrap"><Setting class="menu-icon" /></div>
        <span class="menu-text">设置</span>
        <el-icon class="menu-arrow"><ArrowRight /></el-icon>
      </div>
    </div>

    <!-- Logout -->
    <div class="logout-btn" @click="handleLogout">
      <SwitchButton class="logout-icon" />
      <span>退出登录</span>
    </div>

    <!-- Edit Dialog -->
    <el-dialog v-model="showEditDialog" title="编辑资料" width="90%">
      <el-form :model="editForm" label-width="80px">
        <el-form-item label="昵称">
          <el-input v-model="editForm.nickname" />
        </el-form-item>
        <el-form-item label="邮箱">
          <el-input v-model="editForm.email" />
        </el-form-item>
        <el-form-item label="简介">
          <el-input v-model="editForm.bio" type="textarea" :rows="3" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showEditDialog = false">取消</el-button>
        <el-button type="primary" @click="handleSaveProfile">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Aim, Star, ChatDotRound, User, Edit, Setting, ArrowRight, SwitchButton } from '@element-plus/icons-vue'
import { useAuthStore } from '@/stores/auth'
import { authApi, followApi } from '@/api'

const router = useRouter()
const authStore = useAuthStore()

const user = computed(() => authStore.user)
const userStats = ref({ points: 0, predictions: 0, following: 0 })
const showEditDialog = ref(false)
const editForm = ref<any>({})

function getImageUrl(url: string) {
  if (!url) return ''
  if (url.startsWith('http://') || url.startsWith('https://')) return url
  if (url.startsWith('/uploads/')) return url
  return '/uploads/' + url.replace(/^\//, '')
}

function getRoleLabel(role: string | undefined) {
  const map: Record<string, string> = {
    FAN: '球迷',
    CLUB_ADMIN: '俱乐部管理员',
    SUPER_ADMIN: '超级管理员'
  }
  return map[role || ''] || '用户'
}

async function fetchUserStats() {
  try {
    // Fetch follow count
    const followsRes = await followApi.getMyFollows()
    const follows = followsRes.data.data || []
    userStats.value = {
      points: (user.value as any)?.points || 0,
      predictions: 0,
      following: follows.length
    }
  } catch (e) {
    userStats.value = {
      points: (user.value as any)?.points || 0,
      predictions: 0,
      following: 0
    }
  }
}

function handleLogout() {
  authStore.logout()
  router.push('/login')
}

function handleSaveProfile() {
  // TODO: Implement profile update
  ElMessage.success('资料已更新')
  showEditDialog.value = false
}

onMounted(() => {
  authStore.initAuth()
  if (authStore.isLoggedIn && !authStore.user) {
    authStore.fetchProfile()
  }
  fetchUserStats()

  if (user.value) {
    editForm.value = {
      nickname: user.value.nickname,
      email: user.value.email,
      bio: user.value.bio
    }
  }
})
</script>

<style scoped lang="scss">
.mobile-profile {
  padding: 16px;
}

.user-header {
  text-align: center;
  padding: 24px 16px;
  margin-bottom: 16px;
}

.avatar-wrap {
  margin-bottom: 12px;
}

.avatar {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  object-fit: cover;
  border: 3px solid rgba(124, 58, 237, 0.3);

  &--placeholder {
    background: linear-gradient(135deg, #7c3aed, #6d28d9);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 32px;
    font-weight: 700;
    color: #fff;
  }
}

.username {
  font-size: 20px;
  font-weight: 700;
  color: #fff;
  margin: 0 0 4px;
}

.user-role {
  font-size: 13px;
  color: rgba(255, 255, 255, 0.5);
  margin: 0;
}

.stats-row {
  display: flex;
  justify-content: space-around;
  background: rgba(255, 255, 255, 0.03);
  border-radius: 12px;
  padding: 16px;
  margin-bottom: 20px;
}

.stat-item {
  text-align: center;
}

.stat-value {
  display: block;
  font-size: 22px;
  font-weight: 700;
  background: linear-gradient(135deg, #fbbf24, #f59e0b);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.stat-label {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.5);
}

.menu-list {
  background: rgba(255, 255, 255, 0.03);
  border-radius: 12px;
  overflow: hidden;
}

.menu-item {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 16px 18px;
  min-height: 56px;
  cursor: pointer;
  transition: all 0.2s;
  -webkit-tap-highlight-color: transparent;

  &:active {
    background: rgba(255, 255, 255, 0.06);
  }

  & + & {
    border-top: 1px solid rgba(255, 255, 255, 0.05);
  }
}

.menu-icon-wrap {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  border-radius: 10px;
  background: rgba(124, 58, 237, 0.12);
  flex-shrink: 0;
}

.menu-icon {
  font-size: 18px;
  color: #7c3aed;
}

.menu-text {
  flex: 1;
  font-size: 15px;
  font-weight: 500;
  color: #fff;
  line-height: 1.3;
}

.menu-arrow {
  font-size: 16px;
  color: rgba(255, 255, 255, 0.3);
  flex-shrink: 0;
}

.menu-divider {
  height: 20px;
}

.logout-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  margin-top: 16px;
  padding: 10px;
  background: rgba(239, 68, 68, 0.1);
  border: 1px solid rgba(239, 68, 68, 0.2);
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.2s;
  -webkit-tap-highlight-color: transparent;

  &:active {
    background: rgba(239, 68, 68, 0.2);
  }

  .logout-icon {
    font-size: 15px;
    color: #ef4444;
  }

  span {
    font-size: 13px;
    color: #ef4444;
    font-weight: 500;
  }
}
</style>
