<template>
  <div class="page-container">
    <div class="page-header">
      <h1>聊天室</h1>
    </div>

    <div class="chat-container">
      <div class="chat-messages" ref="messagesRef">
        <div v-for="msg in messages" :key="msg.id" class="message" :class="{ 'own': msg.isOwn }">
          <div class="message-avatar">{{ msg.username?.charAt(0) }}</div>
          <div class="message-content">
            <div class="message-header">
              <span class="message-username">{{ msg.nickname || msg.username }}</span>
              <span v-if="msg.fanClub" class="fan-badge">{{ msg.fanClub }}球迷</span>
              <span class="message-time">{{ formatTime(msg.timestamp || msg.createdAt) }}</span>
            </div>
            <div class="message-text">{{ msg.content }}</div>
          </div>
        </div>
        <div v-if="messages.length === 0" class="empty-state">暂无消息，发送第一条消息吧！</div>
      </div>

      <div class="chat-input">
        <el-input v-model="inputMessage" placeholder="输入消息..." size="large"
          @keyup.enter="sendMessage" :disabled="!isConnected" />
        <AppButton type="primary" size="lg" :disabled="!isConnected || !inputMessage.trim()" @click="sendMessage">
          发送
        </AppButton>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted, nextTick } from 'vue'
import { useAuthStore } from '@/stores/auth'
import AppButton from '@/components/AppButton.vue'

const authStore = useAuthStore()
const messagesRef = ref<HTMLElement>()
const messages = ref<any[]>([])
const inputMessage = ref('')
const isConnected = ref(false)
let ws: WebSocket | null = null

onMounted(() => {
  connectWebSocket()
})

onUnmounted(() => {
  if (ws) {
    ws.close()
  }
})

function connectWebSocket() {
  const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:'
  const wsUrl = `${protocol}//${window.location.hostname}:8080/ws/chat?token=${authStore.token}`

  ws = new WebSocket(wsUrl)

  ws.onopen = () => {
    isConnected.value = true
  }

  ws.onmessage = (event) => {
    const msg = JSON.parse(event.data)
    msg.isOwn = msg.username === authStore.user?.username
    messages.value.push(msg)
    nextTick(() => scrollToBottom())
  }

  ws.onclose = () => {
    isConnected.value = false
  }

  ws.onerror = () => {
    isConnected.value = false
  }
}

function sendMessage() {
  if (!inputMessage.value.trim() || !ws) return

  ws.send(JSON.stringify({
    content: inputMessage.value.trim(),
    type: 'CHAT'
  }))

  inputMessage.value = ''
}

function scrollToBottom() {
  if (messagesRef.value) {
    messagesRef.value.scrollTop = messagesRef.value.scrollHeight
  }
}

function formatTime(timestamp: string) {
  if (!timestamp) return ''
  return new Date(timestamp).toLocaleTimeString('zh-CN', {
    hour: '2-digit',
    minute: '2-digit',
    hour12: false
  })
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
