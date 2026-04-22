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
        <AppButton type="primary" size="large" :disabled="!isConnected || !inputMessage.trim()" @click="sendMessage">
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
.chat-container {
  display: flex;
  flex-direction: column;
  height: calc(100vh - 180px);
  background: #ffffff;
  border-radius: 10px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);
  overflow: hidden;
}

.chat-messages {
  flex: 1;
  overflow-y: auto;
  padding: 18px;

  &::-webkit-scrollbar {
    width: 4px;
  }

  &::-webkit-scrollbar-thumb {
    background: #e5e5e5;
    border-radius: 2px;
  }
}

.message {
  display: flex;
  gap: 10px;
  margin-bottom: 16px;

  &.own {
    flex-direction: row-reverse;

    .message-content {
      align-items: flex-end;

      .message-text {
        background: #1a56db;
        color: white;
      }
    }
  }

  .message-avatar {
    width: 36px;
    height: 36px;
    border-radius: 50%;
    background: rgba(26, 86, 219, 0.1);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 14px;
    color: #1a56db;
    flex-shrink: 0;
  }

  .message-content {
    display: flex;
    flex-direction: column;
    max-width: 60%;

    .message-header {
      display: flex;
      align-items: center;
      gap: 8px;
      margin-bottom: 4px;

      .message-username {
        font-size: 12px;
        font-weight: 500;
        color: #262626;
      }

      .fan-badge {
        font-size: 10px;
        padding: 1px 6px;
        border-radius: 8px;
        background: rgba(26, 86, 219, 0.08);
        color: #1a56db;
        font-weight: 500;
        white-space: nowrap;
      }

      .message-time {
        font-size: 11px;
        color: #a3a3a3;
      }
    }

    .message-text {
      padding: 10px 14px;
      border-radius: 10px;
      background: #f5f5f5;
      font-size: 14px;
      color: #262626;
      line-height: 1.5;
      word-break: break-word;
    }
  }
}

.chat-input {
  display: flex;
  gap: 10px;
  padding: 14px 18px;
  border-top: 1px solid #f0f0f0;
  background: #fafafa;
}

.empty-state {
  text-align: center;
  padding: 40px;
  color: #737373;
  font-size: 14px;
}
</style>
