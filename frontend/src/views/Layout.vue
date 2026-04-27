<template>
  <div class="layout">
    <!-- Top Navigation -->
    <header class="top-nav">
      <div class="nav-brand">
        <router-link to="/" class="logo-link">
          <span class="logo-text">Soccer<span class="logo-highlight">Hub</span></span>
        </router-link>
      </div>
      <div class="nav-search">
        <el-input v-model="searchKeyword" placeholder="搜索俱乐部、球员..." size="default" clearable
          @keyup.enter="handleSearch">
          <template #prefix>
            <el-icon>
              <Search />
            </el-icon>
          </template>
        </el-input>
      </div>
      <div class="nav-actions">
        <el-dropdown @command="handleCommand">
          <span class="user-info">
            <el-avatar :size="32">{{ user?.nickname?.charAt(0) || 'U' }}</el-avatar>
            <span class="username">{{ user?.nickname }}</span>
            <el-icon class="el-icon--right">
              <ArrowDown />
            </el-icon>
          </span>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item command="profile">
                <el-icon>
                  <User />
                </el-icon>
                我的资料
              </el-dropdown-item>
              <el-dropdown-item command="admin" v-if="authStore.isSuperAdmin">
                <el-icon>
                  <Setting />
                </el-icon>
                超级管理面板
              </el-dropdown-item>
              <el-dropdown-item command="club-admin" v-if="authStore.isClubAdmin && !authStore.isSuperAdmin">
                <el-icon>
                  <Setting />
                </el-icon>
                俱乐部管理
              </el-dropdown-item>
              <el-dropdown-item command="logout" divided>
                <el-icon>
                  <SwitchButton />
                </el-icon>
                退出登录
              </el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </header>

    <div class="page-layout">
      <!-- Sidebar -->
      <aside class="sidebar">
        <div class="nav-item" :class="{ active: $route.path === '/' }" @click="$router.push('/')">
          <el-icon>
            <HomeFilled />
          </el-icon>
          <span>首页</span>
        </div>
        <div class="nav-item" :class="{ active: $route.path === '/clubs' }" @click="$router.push('/clubs')">
          <el-icon>
            <Tickets />
          </el-icon>
          <span>俱乐部</span>
        </div>
        <div class="nav-item" :class="{ active: $route.path === '/matches' }" @click="$router.push('/matches')">
          <el-icon>
            <Timer />
          </el-icon>
          <span>赛程</span>
        </div>
        <div class="nav-item" :class="{ active: $route.path === '/rankings' }"
          @click="$router.push('/rankings')">
          <el-icon>
            <TrendCharts />
          </el-icon>
          <span>排行榜</span>
        </div>
        <div class="nav-item" :class="{ active: $route.path === '/standings' }"
          @click="$router.push('/standings')">
          <el-icon>
            <DataLine />
          </el-icon>
          <span>积分榜</span>
        </div>
        <div class="nav-item" :class="{ active: $route.path === '/news' }" @click="$router.push('/news')">
          <el-icon>
            <Document />
          </el-icon>
          <span>资讯</span>
        </div>
        <div class="nav-item" :class="{ active: $route.path === '/community' }" @click="$router.push('/community')">
          <el-icon>
            <ChatDotRound />
          </el-icon>
          <span>社区</span>
        </div>
        <div class="nav-divider"></div>
        <div class="nav-item" :class="{ active: $route.path === '/profile' }" @click="$router.push('/profile')">
          <el-icon>
            <Avatar />
          </el-icon>
          <span>个人中心</span>
        </div>
        <div class="nav-item" v-if="authStore.isSuperAdmin"
          :class="{ active: $route.path === '/admin' }" @click="$router.push('/admin')">
          <el-icon>
            <Setting />
          </el-icon>
          <span>超级管理后台</span>
        </div>
        <div class="nav-item" v-if="authStore.isClubAdmin && !authStore.isSuperAdmin"
          :class="{ active: $route.path === '/club-admin' }" @click="$router.push('/club-admin')">
          <el-icon>
            <Setting />
          </el-icon>
          <span>俱乐部管理</span>
        </div>
        <div class="sidebar-bg"></div>
      </aside>

      <!-- Main Content -->
      <main class="main-content">
        <router-view />
      </main>
    </div>
    <HubBot />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { ElMessage } from 'element-plus'
import HubBot from '@/components/HubBot.vue'

const router = useRouter()
const authStore = useAuthStore()
const searchKeyword = ref('')

const user = computed(() => authStore.user)

onMounted(() => {
  authStore.initAuth()
  if (authStore.isLoggedIn && !authStore.user) {
    authStore.fetchProfile()
  }
})

function handleSearch() {
  if (searchKeyword.value.trim()) {
    router.push({ path: '/players', query: { keyword: searchKeyword.value } })
  }
}

function handleCommand(command: string) {
  switch (command) {
    case 'profile':
      router.push('/profile')
      break
    case 'admin':
      router.push('/admin')
      break
    case 'club-admin':
      router.push('/club-admin')
      break
    case 'logout':
      authStore.logout()
      ElMessage.success('已退出登录')
      router.push('/login')
      break
  }
}
</script>

<style scoped lang="scss">
.layout {
  height: 100vh;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.top-nav {
  height: 60px;
  background: var(--el-bg-color-overlay);
  display: flex;
  align-items: center;
  padding: 0 24px;
  gap: 24px;
  position: sticky;
  top: 0;
  z-index: 100;
  box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
  border-bottom: 1px solid var(--el-border-color-light);

  .nav-brand {
    font-size: 20px;
    font-weight: 700;
    white-space: nowrap;

    .logo-link {
      text-decoration: none;
      display: flex;
      align-items: center;
    }

    .logo-text {
      font-family: 'Inter', 'Segoe UI', sans-serif;
      font-size: 22px;
      font-weight: 800;
      letter-spacing: -0.5px;
      color: var(--el-text-color-primary);
    }

    .logo-highlight {
      color: var(--el-color-primary);
    }
  }

  .nav-search {
    flex: 1;
    max-width: 400px;
    margin-left: 20px;
  }

  .nav-actions {
    margin-left: auto;
  }
}

.user-info {
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  padding: 6px 12px;
  border-radius: 8px;
  transition: all 0.2s;

  &:hover {
    background: var(--el-color-primary-light-9);
  }

  .username {
    font-size: 14px;
    font-weight: 500;
    color: var(--el-text-color-regular);
  }
}

.page-layout {
  display: flex;
  flex: 1;
  overflow: hidden;
}

.sidebar {
  width: 240px;
  background: var(--el-bg-color-overlay);
  border-right: 1px solid var(--el-border-color-light);
  padding-top: 20px;
  flex-shrink: 0;
  position: relative;
  display: flex;
  flex-direction: column;
  overflow-y: auto;
  overflow-x: hidden;
  z-index: 1;
}

.sidebar-bg {
  margin-top: auto;
  width: 100%;
  flex: 1;
  min-height: 400px;
  background-image: url('@/assets/Gemini_Generated_Image_ltf5rfltf5rfltf5.png');
  background-size: cover;
  background-position: center top;
  background-repeat: no-repeat;
  pointer-events: none;
  -webkit-mask-image: linear-gradient(to bottom, transparent 0%, black 10%);
  mask-image: linear-gradient(to bottom, transparent 0%, black 10%);
}

.nav-item {
  padding: 12px 16px;
  margin: 4px 16px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  color: var(--el-text-color-regular);
  font-size: 14px;
  font-weight: 500;

  &:hover {
    background: var(--el-color-primary-light-9);
    color: var(--el-color-primary);
    transform: translateX(4px);
  }

  &.active {
    background: var(--el-color-primary-light-9);
    color: var(--el-color-primary);
    font-weight: 600;
  }
}

.nav-divider {
  height: 1px;
  background: var(--el-border-color-light);
  margin: 16px 24px;
}

.main-content {
  flex: 1;
  overflow-y: auto;
  background: var(--el-bg-color);
}
</style>
