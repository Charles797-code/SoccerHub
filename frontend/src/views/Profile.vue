<template>
  <div class="page-container">
    <div class="page-header">
      <h1>个人中心</h1>
    </div>

    <div v-if="user" class="profile-content">
      <div class="profile-card">
        <div class="profile-avatar">{{ user.nickname?.charAt(0) || user.username?.charAt(0) }}</div>
        <div class="profile-info">
          <h2>{{ user.nickname || user.username }}</h2>
          <span class="role-badge">{{ roleMap[user.role] || user.role }}</span>
          <p class="username">@{{ user.username }}</p>
        </div>
      </div>

      <div class="profile-section">
        <h3>基本信息</h3>
        <div class="info-grid">
          <div class="info-item">
            <span class="info-label">用户名</span>
            <span class="info-value">{{ user.username }}</span>
          </div>
          <div class="info-item">
            <span class="info-label">昵称</span>
            <span class="info-value">{{ user.nickname || '-' }}</span>
          </div>
          <div class="info-item">
            <span class="info-label">邮箱</span>
            <span class="info-value">{{ user.email || '-' }}</span>
          </div>
          <div class="info-item">
            <span class="info-label">角色</span>
            <span class="info-value">{{ roleMap[user.role] || user.role }}</span>
          </div>
        </div>
      </div>

      <div class="profile-section">
        <h3>修改昵称</h3>
        <el-form @submit.prevent="updateNickname">
          <el-form-item>
            <el-input v-model="newNickname" placeholder="输入新昵称" size="default" style="max-width: 300px;" />
            <AppButton type="primary" :loading="nicknameLoading" @click="updateNickname" style="margin-left: 10px;">
              保存
            </AppButton>
          </el-form-item>
        </el-form>
      </div>

      <div class="profile-section">
        <h3>修改密码</h3>
        <el-form @submit.prevent="updatePassword">
          <el-form-item>
            <el-input v-model="oldPassword" type="password" placeholder="当前密码" size="default"
              style="max-width: 300px;" show-password />
          </el-form-item>
          <el-form-item>
            <el-input v-model="newPassword" type="password" placeholder="新密码" size="default"
              style="max-width: 300px;" show-password />
          </el-form-item>
          <el-form-item>
            <AppButton type="primary" :loading="passwordLoading" @click="updatePassword">
              修改密码
            </AppButton>
          </el-form-item>
        </el-form>
      </div>

      <div class="profile-section" v-if="following.length > 0">
        <h3>关注列表</h3>
        <div class="following-list">
          <div v-for="club in following" :key="club.clubId" class="following-item" @click="goToClub(club.clubId)">
            <div class="club-avatar">{{ (club.shortName || club.name)?.charAt(0) }}</div>
            <span class="club-name">{{ club.shortName || club.name }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useAuthStore } from '@/stores/auth'
import { authApi } from '@/api'
import AppButton from '@/components/AppButton.vue'

const router = useRouter()
const authStore = useAuthStore()
const user = ref<any>(null)
const following = ref<any[]>([])
const newNickname = ref('')
const oldPassword = ref('')
const newPassword = ref('')
const nicknameLoading = ref(false)
const passwordLoading = ref(false)

const roleMap: Record<string, string> = {
  SUPER_ADMIN: '超级管理员',
  CLUB_ADMIN: '俱乐部管理员',
  FAN: '球迷'
}

onMounted(async () => {
  try {
    const res = await authApi.getProfile()
    user.value = res.data.data
    newNickname.value = user.value.nickname || ''

    const followRes = await authApi.getMyFollows()
    following.value = followRes.data.data || []
  } catch (e) {
    console.error(e)
  }
})

async function updateNickname() {
  if (!newNickname.value.trim()) {
    ElMessage.warning('昵称不能为空')
    return
  }
  try {
    nicknameLoading.value = true
    await authApi.updateProfile({ nickname: newNickname.value.trim() })
    ElMessage.success('昵称修改成功')
    user.value.nickname = newNickname.value.trim()
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '修改失败')
  } finally {
    nicknameLoading.value = false
  }
}

async function updatePassword() {
  if (!oldPassword.value || !newPassword.value) {
    ElMessage.warning('请填写完整密码信息')
    return
  }
  try {
    passwordLoading.value = true
    await authApi.updateProfile({ oldPassword: oldPassword.value, newPassword: newPassword.value })
    ElMessage.success('密码修改成功')
    oldPassword.value = ''
    newPassword.value = ''
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '修改失败')
  } finally {
    passwordLoading.value = false
  }
}

function goToClub(clubId: number) {
  router.push(`/clubs/${clubId}`)
}
</script>

<style scoped lang="scss">
.profile-card {
  display: flex;
  align-items: center;
  gap: 20px;
  padding: 24px;
  background: #ffffff;
  border-radius: 10px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);
  margin-bottom: 24px;

  .profile-avatar {
    width: 80px;
    height: 80px;
    border-radius: 50%;
    background: rgba(26, 86, 219, 0.1);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 32px;
    color: #1a56db;
    flex-shrink: 0;
  }

  .profile-info {
    h2 {
      margin: 0 0 8px;
      font-size: 22px;
      font-weight: 700;
      color: #262626;
    }

    .role-badge {
      display: inline-block;
      font-size: 12px;
      padding: 3px 10px;
      border-radius: 4px;
      background: rgba(26, 86, 219, 0.1);
      color: #1a56db;
      margin-bottom: 4px;
    }

    .username {
      margin: 4px 0 0;
      font-size: 14px;
      color: #a3a3a3;
    }
  }
}

.profile-section {
  background: #ffffff;
  border-radius: 10px;
  padding: 20px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);
  margin-bottom: 16px;

  h3 {
    margin: 0 0 16px;
    font-size: 16px;
    font-weight: 600;
    color: #262626;
  }
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;

  .info-item {
    .info-label {
      display: block;
      font-size: 12px;
      color: #a3a3a3;
      margin-bottom: 4px;
    }

    .info-value {
      font-size: 15px;
      font-weight: 500;
      color: #262626;
    }
  }
}

.following-list {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.following-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 14px;
  background: #f5f5f5;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s;

  &:hover {
    background: #e5e5e5;
  }

  .club-avatar {
    width: 28px;
    height: 28px;
    border-radius: 50%;
    background: rgba(26, 86, 219, 0.1);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 12px;
    color: #1a56db;
  }

  .club-name {
    font-size: 13px;
    color: #262626;
  }
}
</style>
