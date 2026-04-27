<template>
  <div class="follow-button-container">
    <AppButton
      v-if="isLoggedIn"
      :type="isFollowing ? 'secondary' : 'primary'"
      :loading="loading"
      size="md"
      @click="handleFollow"
    >
      {{ isFollowing ? '已关注' : '关注' }}
    </AppButton>
    <AppButton
      v-else
      type="primary"
      @click="goToLogin"
      size="md"
    >
      登录后关注
    </AppButton>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { followApi } from '@/api'
import { useAuthStore } from '@/stores/auth'
import AppButton from './AppButton.vue'

const authStore = useAuthStore()

const props = defineProps<{
  clubId: number
  clubName?: string
}>()

const loading = ref(false)
const followingClubIds = ref<number[]>([])

const isLoggedIn = computed(() => !!authStore.user)
const isFollowing = computed(() => followingClubIds.value.includes(props.clubId))

onMounted(async () => {
  if (isLoggedIn.value) {
    await fetchFollowing()
  }
})

watch(() => authStore.user, async (newVal) => {
  if (newVal) {
    await fetchFollowing()
  } else {
    followingClubIds.value = []
  }
})

async function fetchFollowing() {
  try {
    const res = await followApi.getMyFollows()
    const follows = res.data.data || []
    followingClubIds.value = follows.map((f: any) => f.clubId)
  } catch (e) {
    console.error(e)
  }
}

async function handleFollow() {
  if (!isLoggedIn.value) {
    goToLogin()
    return
  }

  loading.value = true
  try {
    if (isFollowing.value) {
      await followApi.unfollow(props.clubId)
      followingClubIds.value = followingClubIds.value.filter(id => id !== props.clubId)
      ElMessage.success('已取消关注')
    } else {
      await followApi.follow(props.clubId)
      followingClubIds.value.push(props.clubId)
      ElMessage.success('关注成功')
    }
  } catch (e: any) {
    ElMessage.error(e?.response?.data?.message || '操作失败')
  } finally {
    loading.value = false
  }
}

function goToLogin() {
  window.location.href = '/login'
}
</script>

<style scoped lang="scss">
.follow-button-container {
  display: inline-block;
}
</style>
