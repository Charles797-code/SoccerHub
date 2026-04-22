<template>
  <div class="layout">
    <!-- Top Navigation -->
    <header class="top-nav">
      <div class="nav-brand">
        <router-link to="/">足球社区</router-link>
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
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.top-nav {
  height: 56px;
  background: #1a56db;
  display: flex;
  align-items: center;
  padding: 0 20px;
  gap: 20px;
  position: sticky;
  top: 0;
  z-index: 100;

  .nav-brand {
    font-size: 20px;
    font-weight: 700;
    color: #ffffff;
    white-space: nowrap;
  }

  .nav-search {
    flex: 1;
    max-width: 360px;
  }

  .nav-actions {
    margin-left: auto;
  }
}

.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  padding: 4px 10px;
  border-radius: 8px;
  transition: background 0.2s;

  &:hover {
    background: rgba(255, 255, 255, 0.15);
  }

  .username {
    font-size: 14px;
    color: #ffffff;
  }
}

.page-layout {
  display: flex;
  flex: 1;
}

.sidebar {
  width: 210px;
  background: #ffffff;
  border-right: 1px solid #e5e5e5;
  padding: 12px 0;
  flex-shrink: 0;
}

.nav-item {
  padding: 10px 16px;
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  transition: all 0.15s;
  color: #737373;
  font-size: 14px;
  border-left: 3px solid transparent;

  &:hover {
    background: rgba(26, 86, 219, 0.04);
    color: #262626;
  }

  &.active {
    background: rgba(26, 86, 219, 0.06);
    color: #1a56db;
    font-weight: 500;
    border-left-color: #1a56db;
  }
}

.nav-divider {
  height: 1px;
  background: #f0f0f0;
  margin: 10px 16px;
}

.main-content {
  flex: 1;
  overflow-y: auto;
  background: #f5f5f5;
}
</style>
