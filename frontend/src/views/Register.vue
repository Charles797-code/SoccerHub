<template>
  <div class="register-page">
    <div class="register-card">
      <div class="register-header">
        <h1>SoccerHub</h1>
        <p>加入社区</p>
      </div>

      <el-form ref="formRef" :model="form" :rules="rules" label-position="top" @submit.prevent="handleRegister">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="form.username" placeholder="请输入用户名" size="large" />
        </el-form-item>

        <el-form-item label="昵称" prop="nickname">
          <el-input v-model="form.nickname" placeholder="请输入昵称" size="large" />
        </el-form-item>

        <el-form-item label="邮箱" prop="email">
          <el-input v-model="form.email" placeholder="请输入邮箱（选填）" size="large" type="email" />
        </el-form-item>

        <el-form-item label="密码" prop="password">
          <el-input v-model="form.password" type="password" placeholder="请输入密码" size="large" show-password />
        </el-form-item>

        <el-form-item label="确认密码" prop="confirmPassword">
          <el-input v-model="form.confirmPassword" type="password" placeholder="请再次输入密码" size="large"
            show-password @keyup.enter="handleRegister" />
        </el-form-item>

        <AppButton type="primary" size="lg" :loading="loading" block @click="handleRegister">
          创建账号
        </AppButton>
      </el-form>

      <div class="register-footer">
        <span>已有账号？</span>
        <router-link to="/login">登录</router-link>
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

const form = reactive({
  username: '',
  nickname: '',
  email: '',
  password: '',
  confirmPassword: ''
})

const validateConfirmPassword = (rule: any, value: any, callback: any) => {
  if (value !== form.password) {
    callback(new Error('两次输入的密码不一致'))
  } else {
    callback()
  }
}

const rules: FormRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 50, message: '用户名必须为3-50个字符', trigger: 'blur' }
  ],
  nickname: [
    { required: true, message: '请输入昵称', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码至少需要6个字符', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请再次输入密码', trigger: 'blur' },
    { validator: validateConfirmPassword, trigger: 'blur' }
  ]
}

async function handleRegister() {
  if (!formRef.value) return
  try {
    await formRef.value.validate()
    loading.value = true
    await authStore.register(form.username, form.password, form.nickname, form.email || undefined)
    ElMessage.success('注册成功！请登录。')
    router.push('/login')
  } catch {
  } finally {
    loading.value = false
  }
}
</script>

<style scoped lang="scss">
@use '@/styles/tokens' as *;

.register-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
  background: $surface-dark;
  position: relative;
  overflow: hidden;

  &::before {
    content: '';
    position: absolute;
    top: -50%;
    left: -50%;
    width: 200%;
    height: 200%;
    background: radial-gradient(ellipse at 30% 20%, rgba($purple-primary, 0.08), transparent 50%),
                radial-gradient(ellipse at 70% 80%, rgba($gold-bright, 0.04), transparent 50%);
    pointer-events: none;
  }
}

.register-card {
  width: 100%;
  max-width: 420px;
  background: $surface-card;
  border: 1px solid $border-default;
  border-radius: $radius-2xl;
  padding: $space-10 $space-8;
  box-shadow: $shadow-xl;
  position: relative;

  &::before {
    content: '';
    position: absolute;
    top: 0;
    left: 10%;
    right: 10%;
    height: 1px;
    background: linear-gradient(90deg, transparent, rgba($purple-primary, 0.5), transparent);
  }
}

.register-header {
  text-align: center;
  margin-bottom: $space-8;

  h1 {
    font-family: $font-display;
    font-size: $font-size-3xl;
    font-weight: $font-weight-black;
    margin: 0;
    background: linear-gradient(135deg, $purple-light 0%, $gold-bright 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    letter-spacing: $letter-spacing-tight;
  }

  p {
    color: $text-muted;
    margin: $space-2 0 0;
    font-size: $font-size-base;
  }
}

.register-footer {
  text-align: center;
  margin-top: $space-6;
  color: $text-muted;
  font-size: $font-size-base;

  a {
    color: $purple-light;
    margin-left: $space-1;
    font-weight: $font-weight-medium;
    transition: color $duration-fast $ease-out;

    &:hover {
      color: $gold-bright;
    }
  }
}
</style>
