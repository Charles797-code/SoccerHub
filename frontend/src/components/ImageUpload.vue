<template>
  <div class="image-upload">
    <div class="upload-preview" v-if="modelValue">
      <img :src="getFullUrl(modelValue)" :alt="alt" />
      <div class="preview-actions">
        <el-button size="small" type="primary" @click="triggerUpload">
          <el-icon><Refresh /></el-icon>
        </el-button>
        <el-button size="small" type="danger" @click="removeImage">
          <el-icon><Delete /></el-icon>
        </el-button>
      </div>
    </div>
    <div v-else class="upload-trigger" @click="triggerUpload" @dragover.prevent @drop.prevent="handleDrop">
      <el-icon class="upload-icon"><Plus /></el-icon>
      <span class="upload-text">{{ placeholder }}</span>
    </div>
    <input
      ref="fileInput"
      type="file"
      accept="image/*"
      style="display: none"
      @change="handleFileChange"
    />
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { ElMessage } from 'element-plus'
import { Plus, Delete, Refresh } from '@element-plus/icons-vue'
import { uploadApi } from '@/api'

const props = defineProps<{
  modelValue?: string
  placeholder?: string
  alt?: string
}>()

const emit = defineEmits<{
  (e: 'update:modelValue', value: string): void
}>()

const fileInput = ref<HTMLInputElement>()
const uploading = ref(false)

function triggerUpload() {
  fileInput.value?.click()
}

function handleFileChange(event: Event) {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]
  if (file) {
    uploadImage(file)
  }
}

function handleDrop(event: DragEvent) {
  const file = event.dataTransfer?.files?.[0]
  if (file && file.type.startsWith('image/')) {
    uploadImage(file)
  }
}

async function uploadImage(file: File) {
  if (file.size > 10 * 1024 * 1024) {
    ElMessage.error('图片大小不能超过10MB')
    return
  }

  const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp']
  if (!allowedTypes.includes(file.type)) {
    ElMessage.error('只能上传 JPG、PNG、GIF、WebP 格式的图片')
    return
  }

  uploading.value = true
  try {
    const res = await uploadApi.uploadImage(file)
    if (res.data.success) {
      emit('update:modelValue', res.data.data)
      ElMessage.success('上传成功')
    }
  } catch (e: any) {
    ElMessage.error(e?.response?.data?.message || '上传失败')
  } finally {
    uploading.value = false
  }
}

function removeImage() {
  emit('update:modelValue', '')
}

function getFullUrl(path: string) {
  if (!path) return ''
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return path
  }
  // Handle relative paths - prepend base URL
  const baseUrl = import.meta.env.VITE_API_BASE_URL || ''
  return baseUrl + path
}
</script>

<style scoped lang="scss">
.image-upload {
  width: 120px;
}

.upload-preview {
  position: relative;
  width: 120px;
  height: 120px;
  border-radius: 10px;
  overflow: hidden;
  border: 1px solid #e5e5e5;

  img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }

  .preview-actions {
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    background: rgba(0, 0, 0, 0.6);
    padding: 4px;
    display: flex;
    justify-content: center;
    gap: 4px;
    opacity: 0;
    transition: opacity 0.2s;
  }

  &:hover .preview-actions {
    opacity: 1;
  }
}

.upload-trigger {
  width: 120px;
  height: 120px;
  border: 2px dashed #d9d9d9;
  border-radius: 10px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s;
  background: #fafafa;

  &:hover {
    border-color: #1a56db;
    background: rgba(26, 86, 219, 0.04);
  }

  .upload-icon {
    font-size: 28px;
    color: #bfbfbf;
    margin-bottom: 4px;
  }

  .upload-text {
    font-size: 12px;
    color: #8c8c8c;
  }
}
</style>
