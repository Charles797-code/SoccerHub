<template>
  <div class="layout">
    <!-- Top Navigation -->
    <header class="top-nav">
      <div class="nav-inner">
        <!-- Brand -->
        <router-link to="/" class="logo-link">
          <div class="logo-icon">
            <svg width="28" height="28" viewBox="0 0 28 28" fill="none">
              <circle cx="14" cy="14" r="13" stroke="url(#logoGrad)" stroke-width="2"/>
              <path d="M14 5C14 5 8 9 8 14.5C8 17.5 10.5 20 14 20C17.5 20 20 17.5 20 14.5C20 9 14 5 14 5Z" fill="url(#logoGrad)" opacity="0.9"/>
              <path d="M5 14C5 14 8 10 14 10C20 10 23 14 23 14" stroke="url(#logoGrad)" stroke-width="1.5" stroke-linecap="round"/>
              <defs>
                <linearGradient id="logoGrad" x1="0" y1="0" x2="28" y2="28">
                  <stop stop-color="#7c3aed"/>
                  <stop offset="1" stop-color="#fbbf24"/>
                </linearGradient>
              </defs>
            </svg>
          </div>
          <span class="logo-text">Soccer<span class="logo-highlight">Hub</span></span>
        </router-link>

        <!-- Search -->
        <div class="nav-search">
          <el-input
            v-model="searchKeyword"
            placeholder="搜索俱乐部、球员..."
            size="default"
            clearable
            class="search-input"
            @keyup.enter="handleSearch"
          >
            <template #prefix>
              <Search class="search-icon" />
            </template>
          </el-input>
        </div>

        <!-- Actions -->
        <div class="nav-actions">
          <!-- Live indicator -->
          <div v-if="hasLiveMatches" class="live-indicator" @click="router.push('/matches')">
            <span class="live-dot"></span>
            <span class="live-text">直播中</span>
          </div>

          <!-- User -->
          <el-dropdown trigger="click" @command="handleCommand">
            <button class="user-btn" type="button">
              <div class="user-avatar">
                <img v-if="user?.avatarUrl" :src="getImageUrl(user.avatarUrl)" :alt="user.nickname" />
                <span v-else>{{ user?.nickname?.charAt(0) || 'U' }}</span>
              </div>
              <span class="user-name">{{ user?.nickname || '游客' }}</span>
              <el-icon class="chevron"><ArrowDown /></el-icon>
            </button>
            <template #dropdown>
              <el-dropdown-menu class="nav-dropdown">
                <el-dropdown-item command="profile" class="dropdown-item">
                  <User class="dropdown-icon" />
                  <span>我的资料</span>
                </el-dropdown-item>
                <el-dropdown-item command="admin" v-if="authStore.isSuperAdmin" class="dropdown-item">
                  <Setting class="dropdown-icon" />
                  <span>超级管理面板</span>
                </el-dropdown-item>
                <el-dropdown-item command="club-admin" v-if="authStore.isClubAdmin && !authStore.isSuperAdmin" class="dropdown-item">
                  <Setting class="dropdown-icon" />
                  <span>俱乐部管理</span>
                </el-dropdown-item>
                <el-dropdown-item command="logout" divided class="dropdown-item dropdown-item--danger">
                  <SwitchButton class="dropdown-icon" />
                  <span>退出登录</span>
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </div>
    </header>

    <!-- Page Layout -->
    <div class="page-layout">
      <!-- Sidebar -->
      <aside class="sidebar">
        <div class="sidebar-inner">
          <nav class="nav-list">
            <div
              v-for="item in navItems"
              :key="item.path"
              class="nav-item"
              :class="{ active: isActive(item.path) }"
              @click="router.push(item.path)"
              role="button"
              tabindex="0"
              @keydown.enter="router.push(item.path)"
            >
              <div class="nav-item-bg"></div>
              <el-icon class="nav-icon">
                <component :is="item.icon" />
              </el-icon>
              <span class="nav-label">{{ item.label }}</span>
              <span v-if="item.badge" class="nav-badge">{{ item.badge }}</span>
            </div>
          </nav>

          <div class="sidebar-footer">
            <div class="divider-line"></div>
            <div
              class="nav-item nav-item--sub"
              :class="{ active: isProfileActive }"
              @click="router.push('/profile')"
              role="button"
              tabindex="0"
              @keydown.enter="router.push('/profile')"
            >
              <el-icon class="nav-icon"><Avatar /></el-icon>
              <span class="nav-label">个人中心</span>
            </div>
            <div
              v-if="authStore.isSuperAdmin"
              class="nav-item nav-item--sub"
              :class="{ active: $route.path === '/admin' }"
              @click="router.push('/admin')"
              role="button"
              tabindex="0"
              @keydown.enter="router.push('/admin')"
            >
              <el-icon class="nav-icon"><Setting /></el-icon>
              <span class="nav-label">管理后台</span>
            </div>
            <div
              v-if="authStore.isClubAdmin && !authStore.isSuperAdmin"
              class="nav-item nav-item--sub"
              :class="{ active: $route.path === '/club-admin' }"
              @click="router.push('/club-admin')"
              role="button"
              tabindex="0"
              @keydown.enter="router.push('/club-admin')"
            >
              <el-icon class="nav-icon"><Setting /></el-icon>
              <span class="nav-label">俱乐部管理</span>
            </div>
          </div>
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
import { ref, computed, onMounted, markRaw } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import {
  HomeFilled, Tickets, Timer, TrendCharts, DataLine,
  Document, ChatDotRound, Avatar, Setting,
  User, Search, ArrowDown, SwitchButton
} from '@element-plus/icons-vue'
import { useAuthStore } from '@/stores/auth'
import { matchApi } from '@/api'
import HubBot from '@/components/HubBot.vue'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()

const searchKeyword = ref('')
const hasLiveMatches = ref(false)

const user = computed(() => authStore.user)

const navItems: Array<{ path: string; label: string; icon: any; badge?: string }> = [
  { path: '/', label: '首页', icon: markRaw(HomeFilled) },
  { path: '/clubs', label: '俱乐部', icon: markRaw(Tickets) },
  { path: '/matches', label: '赛程', icon: markRaw(Timer) },
  { path: '/rankings', label: '排行榜', icon: markRaw(TrendCharts) },
  { path: '/standings', label: '积分榜', icon: markRaw(DataLine) },
  { path: '/news', label: '资讯', icon: markRaw(Document) },
  { path: '/community', label: '社区', icon: markRaw(ChatDotRound) },
]

const isProfileActive = computed(() => route.path === '/profile')
const isAdminActive = computed(() => route.path === '/admin' || route.path === '/club-admin')

function isActive(path: string) {
  if (path === '/') return route.path === '/'
  return route.path.startsWith(path)
}

function getImageUrl(path: string) {
  if (!path) return ''
  if (path.startsWith('http://') || path.startsWith('https://')) return path
  return '/api' + path
}

onMounted(async () => {
  authStore.initAuth()
  if (authStore.isLoggedIn && !authStore.user) {
    authStore.fetchProfile()
  }
  try {
    const res = await matchApi.getLive()
    hasLiveMatches.value = (res.data.data?.length || 0) > 0
  } catch { /* ignore */ }
})

function handleSearch() {
  if (searchKeyword.value.trim()) {
    router.push({ path: '/players', query: { keyword: searchKeyword.value } })
  }
}

function handleCommand(command: string) {
  switch (command) {
    case 'profile': router.push('/profile'); break
    case 'admin': router.push('/admin'); break
    case 'club-admin': router.push('/club-admin'); break
    case 'logout':
      authStore.logout()
      router.push('/login')
      break
  }
}
</script>

<style scoped lang="scss">
@use '@/styles/tokens' as *;

// --------------------------------------------------------------------------
// Layout Root
// --------------------------------------------------------------------------

.layout {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: $surface-dark;
}

// --------------------------------------------------------------------------
// Top Navigation
// --------------------------------------------------------------------------

.top-nav {
  position: sticky;
  top: 0;
  z-index: $z-sticky;
  height: $header-height;
  @include glass-surface(0.75);
  border-bottom: 1px solid $border-subtle;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.4), 0 1px 0 0 rgba($purple-primary, 0.08);
}

.nav-inner {
  display: flex;
  align-items: center;
  height: 100%;
  padding: 0 $space-6;
  gap: $space-6;
  max-width: 100%;
}

// Logo
.logo-link {
  display: flex;
  align-items: center;
  gap: $space-3;
  text-decoration: none;
  flex-shrink: 0;
}

.logo-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  filter: drop-shadow(0 0 8px rgba($purple-primary, 0.4));
}

.logo-text {
  font-family: $font-display;
  font-size: 20px;
  font-weight: $font-weight-bold;
  color: $text-primary;
  letter-spacing: -0.5px;
  text-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
}

.logo-highlight {
  @include text-gradient($gold-bright, $gold-dark);
}

// Search
.nav-search {
  flex: 1;
  max-width: 380px;
}

.search-input {
  :deep(.el-input__wrapper) {
    background: rgba($surface-card, 0.6) !important;
    border: 1px solid $border-default !important;
    border-radius: $radius-full !important;
    padding: 2px $space-4 !important;
    transition: all $duration-normal $ease-out;

    &:hover {
      border-color: rgba($purple-primary, 0.5) !important;
      background: rgba($surface-card, 0.8) !important;
    }

    &.is-focus {
      border-color: $purple-primary !important;
      box-shadow: 0 0 0 3px rgba($purple-primary, 0.15), 0 0 12px rgba($purple-primary, 0.1) !important;
      background: rgba($surface-card, 0.9) !important;
    }
  }

  :deep(.el-input__inner) {
    color: $text-primary !important;
    font-size: $font-size-base;

    &::placeholder {
      color: $text-muted !important;
    }
  }
}

.search-icon {
  width: 16px;
  height: 16px;
  color: $text-muted;
}

// Actions
.nav-actions {
  display: flex;
  align-items: center;
  gap: $space-4;
  margin-left: auto;
}

.live-indicator {
  display: flex;
  align-items: center;
  gap: $space-2;
  padding: $space-1 $space-3;
  background: rgba($danger, 0.12);
  border: 1px solid rgba($danger, 0.25);
  border-radius: $radius-full;
  cursor: pointer;
  transition: all $duration-fast $ease-out;

  &:hover {
    background: rgba($danger, 0.18);
    border-color: rgba($danger, 0.4);
  }
}

.live-dot {
  width: 8px;
  height: 8px;
  background: $danger;
  border-radius: $radius-full;
  animation: livePulse 2s ease-in-out infinite;
  box-shadow: 0 0 6px rgba($danger, 0.8);
}

@keyframes livePulse {
  0%, 100% { opacity: 1; transform: scale(1); }
  50% { opacity: 0.6; transform: scale(0.85); }
}

.live-text {
  font-size: $font-size-xs;
  font-weight: $font-weight-semibold;
  color: $danger-light;
  letter-spacing: 0.5px;
  text-transform: uppercase;
}

.user-btn {
  display: flex;
  align-items: center;
  gap: $space-2;
  padding: $space-1 $space-3 $space-1 $space-1;
  background: rgba($surface-card, 0.5);
  border: 1px solid $border-default;
  border-radius: $radius-full;
  cursor: pointer;
  transition: all $duration-fast $ease-out;
  @include focus-ring;

  &:hover {
    background: rgba($surface-card, 0.8);
    border-color: rgba($purple-primary, 0.4);
  }
}

.user-avatar {
  width: 32px;
  height: 32px;
  border-radius: $radius-full;
  background: linear-gradient(135deg, $purple-primary, $gold-dark);
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: $font-display;
  font-size: $font-size-sm;
  font-weight: $font-weight-bold;
  color: $text-primary;
  overflow: hidden;
  border: 1.5px solid rgba($purple-light, 0.3);
  flex-shrink: 0;

  img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }
}

.user-name {
  font-size: $font-size-sm;
  font-weight: $font-weight-medium;
  color: $text-primary;
  max-width: 100px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.chevron {
  width: 14px;
  height: 14px;
  color: $text-muted;
  transition: transform $duration-fast $ease-out;
}

.nav-dropdown {
  background: $surface-mid !important;
  border: 1px solid $border-default !important;
  border-radius: $radius-lg !important;
  box-shadow: $shadow-xl !important;
  padding: $space-1 0 !important;
  min-width: 200px !important;
  overflow: hidden;
}

.dropdown-item {
  display: flex !important;
  align-items: center !important;
  gap: $space-3 !important;
  padding: $space-2 $space-4 !important;
  font-size: $font-size-base !important;
  color: $text-primary !important;
  transition: all $duration-fast $ease-out !important;
  border-radius: 0 !important;

  &:hover {
    background: rgba($purple-primary, 0.12) !important;
    color: $purple-light !important;
  }

  &--danger:hover {
    background: rgba($danger, 0.12) !important;
    color: $danger-light !important;
  }
}

.dropdown-icon {
  width: 16px;
  height: 16px;
  flex-shrink: 0;
}

// --------------------------------------------------------------------------
// Page Layout
// --------------------------------------------------------------------------

.page-layout {
  display: flex;
  flex: 1;
}

// --------------------------------------------------------------------------
// Sidebar
// --------------------------------------------------------------------------

.sidebar {
  width: $sidebar-width;
  flex-shrink: 0;
  @include glass-surface(0.4);
  border-right: 1px solid $border-subtle;
  position: sticky;
  top: $header-height;
  height: calc(100vh - $header-height);
  overflow-y: auto;
  overflow-x: hidden;
}

.sidebar-inner {
  display: flex;
  flex-direction: column;
  height: 100%;
  padding: $space-3 0;
}

.nav-list {
  flex: 1;
  padding: 0 $space-2;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.nav-item {
  position: relative;
  display: flex;
  align-items: center;
  gap: $space-3;
  padding: $space-3 $space-3;
  border-radius: $radius-md;
  cursor: pointer;
  transition: all $duration-normal $ease-out;
  overflow: hidden;
  user-select: none;

  &-bg {
    position: absolute;
    inset: 0;
    border-radius: $radius-md;
    opacity: 0;
    transition: opacity $duration-normal $ease-out;
    background: linear-gradient(
      90deg,
      rgba($purple-primary, 0.2) 0%,
      rgba($purple-primary, 0.08) 100%
    );
    border: 1px solid rgba($purple-primary, 0.15);
  }

  &:hover {
    .nav-item-bg { opacity: 0.6; }
    .nav-icon { color: $purple-light; transform: scale(1.05); }
    .nav-label { color: $text-primary; }
  }

  &.active {
    .nav-item-bg { opacity: 1; }
    .nav-icon {
      color: $purple-primary;
      filter: drop-shadow(0 0 6px rgba($purple-primary, 0.6));
    }
    .nav-label {
      color: $text-primary;
      font-weight: $font-weight-semibold;
    }
  }

  &--sub {
    margin-top: 2px;
  }
}

.nav-icon {
  width: 20px;
  height: 20px;
  color: $text-muted;
  flex-shrink: 0;
  transition: all $duration-normal $ease-spring;
  position: relative;
  z-index: 1;
}

.nav-label {
  font-size: $font-size-base;
  font-weight: $font-weight-medium;
  color: $text-secondary;
  position: relative;
  z-index: 1;
  transition: color $duration-fast $ease-out;
}

.nav-badge {
  margin-left: auto;
  padding: 1px 6px;
  background: rgba($danger, 0.15);
  color: $danger-light;
  font-size: $font-size-xs;
  font-weight: $font-weight-bold;
  border-radius: $radius-full;
  border: 1px solid rgba($danger, 0.25);
  position: relative;
  z-index: 1;
}

// --------------------------------------------------------------------------
// Sidebar Footer
// --------------------------------------------------------------------------

.sidebar-footer {
  padding: 0 $space-2;
  margin-top: auto;
}

.divider-line {
  height: 1px;
  background: $border-subtle;
  margin: $space-2 $space-1 $space-2;
}

// --------------------------------------------------------------------------
// Main Content
// --------------------------------------------------------------------------

.main-content {
  flex: 1;
  overflow-y: auto;
  min-width: 0;
  background: $surface-dark;

  // Subtle background pattern
  &::before {
    content: '';
    position: fixed;
    top: $header-height;
    left: $sidebar-width;
    right: 0;
    bottom: 0;
    background:
      radial-gradient(ellipse 80% 50% at 20% -10%, rgba($purple-primary, 0.06) 0%, transparent 60%),
      radial-gradient(ellipse 60% 40% at 80% 110%, rgba($gold-dark, 0.03) 0%, transparent 50%);
    pointer-events: none;
    z-index: 0;
  }

  > * {
    position: relative;
    z-index: 1;
  }
}

// --------------------------------------------------------------------------
// Reduced Motion
// --------------------------------------------------------------------------

@media (prefers-reduced-motion: reduce) {
  .live-dot {
    animation: none;
  }

  .nav-item {
    transition: none;
  }

  .user-btn, .search-input :deep(.el-input__wrapper) {
    transition: none;
  }
}
</style>
