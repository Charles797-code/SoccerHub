import { defineStore } from 'pinia'
import { ref } from 'vue'
import type { RouteLocationNormalized } from 'vue-router'

interface TabItem {
  path: string
  name: string
  title: string
}

export const useAppStore = defineStore('app', () => {
  const sidebarCollapsed = ref(false)
  const tabs = ref<TabItem[]>([])
  const activeTab = ref('')

  function toggleSidebar() {
    sidebarCollapsed.value = !sidebarCollapsed.value
  }

  function addTab(route: RouteLocationNormalized) {
    const existing = tabs.value.find(t => t.path === route.path)
    if (!existing) {
      tabs.value.push({
        path: route.path,
        name: route.name as string,
        title: (route.meta?.title as string) || route.name as string
      })
    }
    activeTab.value = route.path
  }

  function removeTab(path: string) {
    const index = tabs.value.findIndex(t => t.path === path)
    if (index > -1) {
      tabs.value.splice(index, 1)
    }
  }

  return {
    sidebarCollapsed,
    tabs,
    activeTab,
    toggleSidebar,
    addTab,
    removeTab
  }
})
