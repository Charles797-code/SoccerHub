<template>
  <div class="mobile-layout">
    <!-- Header -->
    <header class="mobile-header">
      <div class="header-content">
        <router-link to="/m" class="logo">
          <svg width="24" height="24" viewBox="0 0 28 28" fill="none">
            <circle cx="14" cy="14" r="13" stroke="url(#logoGradM)" stroke-width="2"/>
            <path d="M14 5C14 5 8 9 8 14.5C8 17.5 10.5 20 14 20C17.5 20 20 17.5 20 14.5C20 9 14 5 14 5Z" fill="url(#logoGradM)" opacity="0.9"/>
            <defs>
              <linearGradient id="logoGradM" x1="0" y1="0" x2="28" y2="28">
                <stop stop-color="#7c3aed"/>
                <stop offset="1" stop-color="#fbbf24"/>
              </linearGradient>
            </defs>
          </svg>
          <span class="logo-text">Soccer<span class="accent">Hub</span></span>
        </router-link>
        <div class="header-actions">
          <button class="icon-btn" @click="goSearch">
            <Search />
          </button>
          <button class="icon-btn" @click="router.push('/m/profile')">
            <User />
          </button>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="mobile-main">
      <router-view v-slot="{ Component }">
        <transition name="fade-slide" mode="out-in">
          <component :is="Component" />
        </transition>
      </router-view>
    </main>

    <!-- Bottom Tab Bar -->
    <nav class="bottom-nav">
      <div
        v-for="item in tabItems"
        :key="item.path"
        class="tab-item"
        :class="{ active: isActive(item.path) }"
        @click="router.push(item.path)"
      >
        <div class="tab-icon">
          <component :is="item.icon" />
        </div>
        <span class="tab-label">{{ item.label }}</span>
      </div>
    </nav>
  </div>
</template>

<script setup lang="ts">
import { markRaw } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import {
  HomeFilled, Tickets, Timer, TrendCharts, Avatar, Search, User, Document
} from '@element-plus/icons-vue'

const router = useRouter()
const route = useRoute()

const tabItems = [
  { path: '/m', label: '首页', icon: markRaw(HomeFilled) },
  { path: '/m/clubs', label: '俱乐部', icon: markRaw(Tickets) },
  { path: '/m/matches', label: '赛程', icon: markRaw(Timer) },
  { path: '/m/standings', label: '积分榜', icon: markRaw(TrendCharts) },
  { path: '/m/news', label: '资讯', icon: markRaw(Document) },
]

function isActive(path: string) {
  if (path === '/m') return route.path === '/m'
  return route.path.startsWith(path)
}

function goSearch() {
  router.push('/m/search')
}
</script>

<style scoped lang="scss">
@use '@/styles/tokens' as *;

.mobile-layout {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: $surface-dark;
  color: #fff;
  position: relative;

  // Background effects like PC version
  &::before {
    content: '';
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background:
      radial-gradient(ellipse 60% 40% at 20% -10%, rgba($purple-primary, 0.08) 0%, transparent 60%),
      radial-gradient(ellipse 50% 30% at 80% 110%, rgba($gold-dark, 0.04) 0%, transparent 50%);
    pointer-events: none;
    z-index: 0;
  }

  > * {
    position: relative;
    z-index: 1;
  }
}

// Header
.mobile-header {
  position: sticky;
  top: 0;
  z-index: 100;
  @include glass-surface(0.75);
  border-bottom: 1px solid $border-subtle;
}

.header-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 16px;
  max-width: 100%;
}

.logo {
  display: flex;
  align-items: center;
  gap: 8px;
  text-decoration: none;
}

.logo-text {
  font-family: $font-display;
  font-size: 18px;
  font-weight: $font-weight-bold;
  color: #fff;
}

.accent {
  color: #fbbf24;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 8px;
}

.icon-btn {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.06);
  border: none;
  color: rgba(255, 255, 255, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s;

  &:active {
    background: rgba(255, 255, 255, 0.1);
    transform: scale(0.95);
  }
}

// Main Content
.mobile-main {
  flex: 1;
  padding-bottom: 70px;
  overflow-y: auto;
}

// Bottom Nav
.bottom-nav {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  z-index: 100;
  @include glass-surface(0.85);
  border-top: 1px solid $border-subtle;
  display: flex;
  justify-content: space-around;
  padding: 8px 0;
  padding-bottom: max(8px, env(safe-area-inset-bottom));
}

.tab-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
  padding: 6px 16px;
  cursor: pointer;
  transition: all 0.2s;
  -webkit-tap-highlight-color: transparent;

  &.active {
    .tab-icon {
      color: #7c3aed;
    }
    .tab-label {
      color: #7c3aed;
      font-weight: 600;
    }
  }
}

.tab-icon {
  font-size: 22px;
  color: rgba(255, 255, 255, 0.5);
  transition: all 0.2s;
}

.tab-label {
  font-size: 11px;
  color: rgba(255, 255, 255, 0.5);
  transition: all 0.2s;
}

// Page transitions
.fade-slide-enter-active,
.fade-slide-leave-active {
  transition: all 0.2s ease;
}

.fade-slide-enter-from {
  opacity: 0;
  transform: translateX(20px);
}

.fade-slide-leave-to {
  opacity: 0;
  transform: translateX(-20px);
}
</style>
