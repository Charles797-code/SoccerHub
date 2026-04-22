<template>
  <div class="login-page">
    <div class="login-card">
      <div class="login-header">
        <h1>SoccerHub</h1>
        <p>您的专业足球资讯与社区平台</p>
      </div>

      <el-form ref="formRef" :model="form" :rules="rules" label-position="top" @submit.prevent="handleLogin">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="form.username" placeholder="请输入用户名" size="large" prefix-icon="User" />
        </el-form-item>

        <el-form-item label="密码" prop="password">
          <el-input v-model="form.password" type="password" placeholder="请输入密码" size="large"
            prefix-icon="Lock" show-password @keyup.enter="handleLogin" />
        </el-form-item>

        <AppButton type="primary" size="large" :loading="loading" block @click="handleLogin">
          登录
        </AppButton>
      </el-form>

      <div class="login-footer">
        <span>还没有账号？</span>
        <router-link to="/register">注册</router-link>
      </div>

      <div class="demo-hint">
        <el-divider>演示账号</el-divider>
        <div class="demo-accounts">
          <el-tag v-for="acc in demoAccounts" :key="acc.username" class="demo-tag" @click="fillDemo(acc)">
            <span class="demo-role">{{ roleMap[acc.role] }}</span>
            <span class="demo-user">{{ acc.username }}</span>
          </el-tag>
        </div>
        <p class="demo-note">密码: admin123</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import { useAuthStore } from '@/stores/auth'
import AppButton from '@/components/AppButton.vue'

const router = useRouter()
const authStore = useAuthStore()
const formRef = ref<FormInstance>()
const loading = ref(false)

const roleMap: Record<string, string> = {
  SUPER_ADMIN: '超级管理员',
  CLUB_ADMIN: '俱乐部管理员',
  FAN: '球迷'
}

const form = reactive({
  username: '',
  password: ''
})

const rules: FormRules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

const demoAccounts = [
  { username: 'admin', role: 'SUPER_ADMIN' },
  { username: 'arsenal_admin', role: 'CLUB_ADMIN' },
  { username: 'madrid_admin', role: 'CLUB_ADMIN' },
  { username: 'zhangsan', role: 'FAN' }
]

function fillDemo(acc: { username: string }) {
  form.username = acc.username
  form.password = 'admin123'
}

async function handleLogin() {
  if (!formRef.value) return
  try {
    await formRef.value.validate()
    loading.value = true
    await authStore.login(form.username, form.password)
    ElMessage.success('登录成功！')
    router.push('/')
  } catch {
  } finally {
    loading.value = false
  }
}
</script>

<style scoped lang="scss">
.login-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
  background: #f5f5f5;
}

.login-card {
  width: 100%;
  max-width: 400px;
  background: #ffffff;
  border-radius: 12px;
  padding: 36px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
}

.login-header {
  text-align: center;
  margin-bottom: 28px;

  h1 {
    font-size: 26px;
    font-weight: 700;
    margin: 0;
    color: #262626;
    letter-spacing: -0.3px;
  }

  p {
    color: #737373;
    margin: 8px 0 0;
    font-size: 14px;
  }
}

.login-footer {
  text-align: center;
  margin-top: 20px;
  color: #737373;
  font-size: 14px;

  a {
    color: #1a56db;
    margin-left: 4px;

    &:hover {
      text-decoration: underline;
    }
  }
}

.demo-hint {
  margin-top: 20px;
}

.demo-accounts {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  justify-content: center;
}

.demo-tag {
  cursor: pointer;
  display: flex;
  gap: 6px;
  padding: 6px 12px;

  &:hover {
    opacity: 0.8;
  }

  .demo-role {
    font-weight: 600;
  }
}

.demo-note {
  text-align: center;
  color: #a3a3a3;
  font-size: 12px;
  margin: 8px 0 0;
}
</style>
