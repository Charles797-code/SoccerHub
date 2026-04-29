<template>
  <div class="chat-container">
    <div class="chat-messages" ref="messagesContainer">
      <div v-if="loading" class="chat-loading">
        <span class="loading-spinner"></span>
        加载中...
      </div>
      <div v-else-if="messages.length === 0" class="chat-empty">
        暂无消息，发送第一条消息吧！
      </div>
      <div v-for="msg in messages" :key="msg.messageId" class="message" :class="{ own: msg.userId === currentUserId }">
        <div class="message-avatar">{{ getInitial(msg.userId) }}</div>
        <div class="message-content">
          <div class="message-author">{{ msg.userNickname || '匿名用户' }}</div>
          <div class="message-text">{{ msg.content }}</div>
          <div class="message-time">{{ formatTime(msg.createdAt) }}</div>
        </div>
      </div>
    </div>
    <div class="chat-input-area">
      <el-input v-model="newMessage" placeholder="输入消息..." size="large" @keyup.enter="sendMessage"
        :disabled="sending" />
      <AppButton type="primary" size="md" :loading="sending" @click="sendMessage" style="flex-shrink: 0;">
        发送
      </AppButton>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted, nextTick } from 'vue'
import { ElMessage } from 'element-plus'
import SockJS from 'sockjs-client'
import { Client } from '@stomp/stompjs'
import { chatApi } from '@/api'
import { useAuthStore } from '@/stores/auth'
import AppButton from './AppButton.vue'

const props = defineProps<{
  clubId: number
  clubName?: string
}>()

const authStore = useAuthStore()
const messages = ref<any[]>([])
const newMessage = ref('')
const loading = ref(false)
const sending = ref(false)
const messagesContainer = ref<HTMLElement>()
let stompClient: any = null

const currentUserId = authStore.user?.userId

function getInitial(userId: number) {
  return String(userId || 'U').charAt(0)
}

onMounted(async () => {
  await fetchMessages()
  connectWebSocket()
})

onUnmounted(() => {
  if (stompClient) {
    stompClient.deactivate()
  }
})

async function fetchMessages() {
  loading.value = true
  try {
    const res = await chatApi.getRecent(props.clubId, 100)
    messages.value = res.data.data || []
    scrollToBottom()
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
}

function connectWebSocket() {
  try {
    const client = new Client({
      webSocketFactory: () => new SockJS('/api/ws/chat'),
      reconnectDelay: 5000,
      onConnect: () => {
        client.subscribe(`/topic/chat/${props.clubId}`, (frame: any) => {
          const msg = JSON.parse(frame.body)
          if (msg.userId !== currentUserId) {
            messages.value.push(msg)
            nextTick(() => scrollToBottom())
          }
        })
      },
      onStompError: (frame: any) => {
        console.warn('STOMP error', frame)
      }
    })
    client.activate()
    stompClient = client
  } catch (e) {
    console.warn('WebSocket not available', e)
  }
}

async function sendMessage() {
  if (!newMessage.value.trim()) return
  sending.value = true
  try {
    const res = await chatApi.send(props.clubId, newMessage.value.trim())
    messages.value.push(res.data.data)
    newMessage.value = ''
    nextTick(() => scrollToBottom())
  } catch (e: any) {
    ElMessage.error(e?.response?.data?.message || '发送失败')
  } finally {
    sending.value = false
  }
}

function scrollToBottom() {
  if (messagesContainer.value) {
    messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight
  }
}

function formatTime(time: string) {
  if (!time) return ''
  return new Date(time).toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit', hour12: false })
}
</script>

<style scoped lang="scss">
.chat-container {
  display: flex;
  flex-direction: column;
  height: 500px;
  background: #ffffff;
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);
}

.chat-messages {
  flex: 1;
  overflow-y: auto;
  padding: 12px;
  display: flex;
  flex-direction: column;
  gap: 10px;
  background: #f5f5f5;
}

.chat-loading {
  text-align: center;
  padding: 40px;
  color: #737373;
  font-size: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  flex: 1;
}

.loading-spinner {
  display: inline-block;
  width: 16px;
  height: 16px;
  border: 2px solid rgba(26, 86, 219, 0.2);
  border-top-color: #1a56db;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.chat-empty {
  text-align: center;
  padding: 40px;
  color: #a3a3a3;
  font-size: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex: 1;
}

.message {
  display: flex;
  gap: 8px;
  max-width: 85%;

  &.own {
    flex-direction: row-reverse;
    align-self: flex-end;

    .message-content {
      background: #1a56db;
      color: white;

      .message-author {
        color: rgba(255, 255, 255, 0.75);
      }

      .message-time {
        color: rgba(255, 255, 255, 0.6);
      }
    }
  }

  .message-avatar {
    width: 32px;
    height: 32px;
    border-radius: 50%;
    background: linear-gradient(135deg, #1a56db, #3b82f6);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 13px;
    color: white;
    flex-shrink: 0;
  }

  .message-content {
    background: #ffffff;
    border-radius: 8px;
    padding: 8px 12px;
    min-width: 0;

    .message-author {
      font-size: 11px;
      color: #1a56db;
      font-weight: 500;
      margin-bottom: 2px;
    }

    .message-text {
      font-size: 14px;
      line-height: 1.5;
      word-break: break-word;
    }

    .message-time {
      font-size: 10px;
      color: #a3a3a3;
      margin-top: 4px;
      text-align: right;
    }
  }
}

.chat-input-area {
  padding: 12px;
  background: #ffffff;
  display: flex;
  gap: 10px;
  border-top: 1px solid #f0f0f0;
}
</style>
