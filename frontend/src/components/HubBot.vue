<template>
  <div class="hub-bot" ref="hubBotRef" :style="panelStyle">
    <transition name="chat-fade">
      <div v-if="isOpen" class="chat-panel">
        <div class="chat-header" @mousedown.left="startDrag">
          <div class="chat-header-left">
            <span class="bot-avatar">⚽</span>
            <div>
              <div class="bot-name">Hub球宝</div>
              <div class="bot-status">在线</div>
            </div>
          </div>
          <el-button text @click="isOpen = false" @mousedown.stop>
            <el-icon :size="18"><Close /></el-icon>
          </el-button>
        </div>

        <div class="chat-messages" ref="messagesRef">
          <div v-for="(msg, idx) in messages" :key="idx" :class="['chat-msg', msg.role === 'user' ? 'msg-user' : 'msg-bot']">
            <div v-if="msg.role === 'bot'" class="msg-avatar">⚽</div>
            <div class="msg-bubble">
              <div v-if="msg.loading" class="msg-loading">
                <span></span><span></span><span></span>
              </div>
              <div v-else class="msg-text" v-html="formatMessage(msg.content)"></div>
            </div>
          </div>
        </div>

        <div class="chat-quick">
          <el-tag
            v-for="q in quickQuestions"
            :key="q"
            size="small"
            class="quick-tag"
            @click="sendQuick(q)"
          >{{ q }}</el-tag>
        </div>

        <div class="chat-input">
          <el-input
            v-model="inputText"
            placeholder="问我任何足球问题..."
            @keyup.enter="sendMessage"
            :disabled="loading"
            size="large"
          >
            <template #append>
              <el-button :loading="loading" @click="sendMessage">
                <el-icon><Promotion /></el-icon>
              </el-button>
            </template>
          </el-input>
        </div>
      </div>
    </transition>

    <div v-if="!isOpen" class="chat-trigger" @click="isOpen = true">
      <span class="trigger-icon">⚽</span>
      <span class="trigger-text">Hub球宝</span>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, nextTick, onMounted, onBeforeUnmount, computed } from 'vue'
import { Close, Promotion } from '@element-plus/icons-vue'
import api from '@/api'

interface ChatMessage {
  role: 'user' | 'bot'
  content: string
  loading?: boolean
}

const isOpen = ref(false)
const inputText = ref('')
const loading = ref(false)
const messages = ref<ChatMessage[]>([])
const messagesRef = ref<HTMLElement>()
const hubBotRef = ref<HTMLElement>()

const dragState = ref({ dragging: false, startX: 0, startY: 0, offsetX: 0, offsetY: 0 })
const panelPos = ref({ right: 24, bottom: 24 })

const panelStyle = computed(() => ({
  right: panelPos.value.right + 'px',
  bottom: panelPos.value.bottom + 'px'
}))

function startDrag(e: MouseEvent) {
  dragState.value.dragging = true
  dragState.value.startX = e.clientX
  dragState.value.startY = e.clientY
  dragState.value.offsetX = 0
  dragState.value.offsetY = 0
  document.addEventListener('mousemove', onDrag)
  document.addEventListener('mouseup', stopDrag)
}

function onDrag(e: MouseEvent) {
  if (!dragState.value.dragging) return
  const dx = e.clientX - dragState.value.startX
  const dy = e.clientY - dragState.value.startY
  dragState.value.offsetX = dx
  dragState.value.offsetY = dy
  panelPos.value.right = Math.max(0, panelPos.value.right - dx)
  panelPos.value.bottom = Math.max(0, panelPos.value.bottom - dy)
  dragState.value.startX = e.clientX
  dragState.value.startY = e.clientY
}

function stopDrag() {
  dragState.value.dragging = false
  document.removeEventListener('mousemove', onDrag)
  document.removeEventListener('mouseup', stopDrag)
}

onBeforeUnmount(() => {
  document.removeEventListener('mousemove', onDrag)
  document.removeEventListener('mouseup', stopDrag)
})

const quickQuestions = ['姆巴佩在哪个俱乐部？', '英超有哪些球队？', '最近的比赛结果', '阿森纳的教练是谁？']

onMounted(() => {
  messages.value.push({
    role: 'bot',
    content: '你好！我是Hub球宝 ⚽ 你的专属足球AI助手！\n我可以回答关于球员、俱乐部、比赛、转会等足球问题，快问我吧！'
  })
})

async function sendMessage() {
  const text = inputText.value.trim()
  if (!text || loading.value) return

  messages.value.push({ role: 'user', content: text })
  inputText.value = ''
  loading.value = true

  const botMsg: ChatMessage = { role: 'bot', content: '', loading: true }
  messages.value.push(botMsg)
  await scrollToBottom()

  try {
    const res = await api.post('/ai/chat', { message: text })
    botMsg.loading = false
    botMsg.content = res.data.data || '抱歉，我暂时无法回答这个问题。'
  } catch (e: any) {
    botMsg.loading = false
    botMsg.content = '抱歉，服务暂时不可用，请稍后再试。'
  } finally {
    loading.value = false
    await scrollToBottom()
  }
}

function sendQuick(q: string) {
  inputText.value = q
  sendMessage()
}

async function scrollToBottom() {
  await nextTick()
  if (messagesRef.value) {
    messagesRef.value.scrollTop = messagesRef.value.scrollHeight
  }
}

function formatMessage(text: string) {
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/\n/g, '<br/>')
}
</script>

<style scoped lang="scss">
.hub-bot {
  position: fixed;
  bottom: 24px;
  right: 24px;
  z-index: 9999;
}

.chat-trigger {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 20px;
  background: linear-gradient(135deg, #1a56db, #3b82f6);
  color: #fff;
  border-radius: 28px;
  cursor: pointer;
  box-shadow: 0 4px 16px rgba(26, 86, 219, 0.4);
  transition: all 0.3s;
  user-select: none;

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 24px rgba(26, 86, 219, 0.5);
  }

  .trigger-icon {
    font-size: 22px;
  }

  .trigger-text {
    font-size: 15px;
    font-weight: 600;
  }
}

.chat-panel {
  width: 400px;
  height: 560px;
  background: #ffffff;
  border-radius: 16px;
  display: flex;
  flex-direction: column;
  box-shadow: 0 8px 40px rgba(0, 0, 0, 0.15);
  overflow: hidden;
}

.chat-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 18px;
  background: linear-gradient(135deg, #1a56db, #3b82f6);
  color: #fff;
  cursor: move;
  user-select: none;

  .chat-header-left {
    display: flex;
    align-items: center;
    gap: 10px;
  }

  .bot-avatar {
    font-size: 28px;
    line-height: 1;
  }

  .bot-name {
    font-size: 16px;
    font-weight: 700;
  }

  .bot-status {
    font-size: 11px;
    opacity: 0.85;
  }
}

.chat-messages {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
  display: flex;
  flex-direction: column;
  gap: 12px;
  background: #f8fafc;

  &::-webkit-scrollbar {
    width: 4px;
  }

  &::-webkit-scrollbar-thumb {
    background: #d1d5db;
    border-radius: 2px;
  }
}

.chat-msg {
  display: flex;
  align-items: flex-end;
  gap: 8px;

  &.msg-user {
    flex-direction: row-reverse;

    .msg-bubble {
      background: #1a56db;
      color: #fff;
      border-radius: 16px 16px 4px 16px;
    }
  }

  &.msg-bot {
    .msg-bubble {
      background: #ffffff;
      color: #262626;
      border-radius: 16px 16px 16px 4px;
      border: 1px solid #e5e7eb;
    }
  }
}

.msg-avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: #eff6ff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  flex-shrink: 0;
}

.msg-bubble {
  max-width: 280px;
  padding: 10px 14px;
  font-size: 14px;
  line-height: 1.6;
  word-break: break-word;
}

.msg-loading {
  display: flex;
  gap: 5px;
  padding: 4px 0;

  span {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: #9ca3af;
    animation: bounce 1.4s infinite ease-in-out both;

    &:nth-child(1) { animation-delay: -0.32s; }
    &:nth-child(2) { animation-delay: -0.16s; }
  }
}

@keyframes bounce {
  0%, 80%, 100% { transform: scale(0); }
  40% { transform: scale(1); }
}

.chat-quick {
  display: flex;
  gap: 6px;
  padding: 8px 16px;
  overflow-x: auto;
  background: #f8fafc;
  border-top: 1px solid #f0f0f0;

  &::-webkit-scrollbar {
    height: 0;
  }

  .quick-tag {
    cursor: pointer;
    white-space: nowrap;
    transition: all 0.2s;

    &:hover {
      color: #1a56db;
      border-color: #1a56db;
    }
  }
}

.chat-input {
  padding: 12px 16px;
  border-top: 1px solid #e5e7eb;
  background: #fff;

  :deep(.el-input-group__append) {
    padding: 0 12px;
  }
}

.chat-fade-enter-active,
.chat-fade-leave-active {
  transition: all 0.3s ease;
}

.chat-fade-enter-from,
.chat-fade-leave-to {
  opacity: 0;
  transform: translateY(20px) scale(0.95);
}

@media (max-width: 500px) {
  .chat-panel {
    width: calc(100vw - 16px);
    height: calc(100vh - 80px);
    bottom: 0;
    right: 0;
    border-radius: 16px 16px 0 0;
  }

  .hub-bot {
    bottom: 16px;
    right: 16px;
  }
}
</style>
