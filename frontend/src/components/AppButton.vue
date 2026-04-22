<template>
  <button
    class="app-button"
    :class="[
      `app-button--${type}`,
      `app-button--${size}`,
      { 'app-button--loading': loading, 'app-button--block': block }
    ]"
    :disabled="disabled || loading"
    @click="$emit('click', $event)"
  >
    <span v-if="loading" class="app-button__spinner">
      <svg class="app-button__spinner-icon" viewBox="0 0 24 24">
        <circle cx="12" cy="12" r="10" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-dasharray="31.4 31.4" />
      </svg>
    </span>
    <span class="app-button__content" :class="{ 'app-button__content--hidden': loading }">
      <slot />
    </span>
  </button>
</template>

<script setup lang="ts">
defineProps<{
  type?: 'primary' | 'success' | 'danger' | 'warning' | 'default'
  size?: 'small' | 'medium' | 'large'
  loading?: boolean
  disabled?: boolean
  block?: boolean
}>()

defineEmits<{
  click: [event: MouseEvent]
}>()
</script>

<style scoped lang="scss">
.app-button {
  position: relative;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  font-family: inherit;
  font-weight: 600;
  border: none;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
  outline: none;
  white-space: nowrap;
  user-select: none;
  overflow: hidden;

  &:focus-visible {
    box-shadow: 0 0 0 3px rgba(26, 86, 219, 0.25);
  }

  &:disabled {
    cursor: not-allowed;
    opacity: 0.55;
    transform: none !important;
  }

  &:active:not(:disabled) {
    transform: scale(0.97);
  }

  // Sizes
  &--small {
    padding: 7px 14px;
    font-size: 13px;
    border-radius: 8px;
  }

  &--medium {
    padding: 10px 20px;
    font-size: 14px;
  }

  &--large {
    padding: 13px 28px;
    font-size: 15px;
    border-radius: 12px;
  }

  // Block
  &--block {
    width: 100%;
  }

  // Types
  &--primary {
    background: linear-gradient(135deg, #1a56db 0%, #2d6fd9 50%, #3b82f6 100%);
    color: #ffffff;
    box-shadow: 0 2px 8px rgba(26, 86, 219, 0.3), 0 1px 2px rgba(26, 86, 219, 0.15);

    &:not(:disabled):hover {
      background: linear-gradient(135deg, #1444b8 0%, #1a56db 50%, #2563eb 100%);
      box-shadow: 0 4px 16px rgba(26, 86, 219, 0.4), 0 2px 4px rgba(26, 86, 219, 0.2);
      transform: translateY(-1px);
    }
  }

  &--success {
    background: linear-gradient(135deg, #16a34a 0%, #1ea34a 50%, #22c55e 100%);
    color: #ffffff;
    box-shadow: 0 2px 8px rgba(22, 163, 74, 0.3), 0 1px 2px rgba(22, 163, 74, 0.15);

    &:not(:disabled):hover {
      background: linear-gradient(135deg, #138d3e 0%, #16a34a 50%, #1ea34a 100%);
      box-shadow: 0 4px 16px rgba(22, 163, 74, 0.4), 0 2px 4px rgba(22, 163, 74, 0.2);
      transform: translateY(-1px);
    }
  }

  &--danger {
    background: linear-gradient(135deg, #dc2626 0%, #e02a2a 50%, #ef4444 100%);
    color: #ffffff;
    box-shadow: 0 2px 8px rgba(220, 38, 38, 0.3), 0 1px 2px rgba(220, 38, 38, 0.15);

    &:not(:disabled):hover {
      background: linear-gradient(135deg, #b91c1c 0%, #dc2626 50%, #dc3838 100%);
      box-shadow: 0 4px 16px rgba(220, 38, 38, 0.4), 0 2px 4px rgba(220, 38, 38, 0.2);
      transform: translateY(-1px);
    }
  }

  &--warning {
    background: linear-gradient(135deg, #d97706 0%, #e08a06 50%, #f59e0b 100%);
    color: #ffffff;
    box-shadow: 0 2px 8px rgba(217, 119, 6, 0.3), 0 1px 2px rgba(217, 119, 6, 0.15);

    &:not(:disabled):hover {
      background: linear-gradient(135deg, #b45309 0%, #d97706 50%, #e08a06 100%);
      box-shadow: 0 4px 16px rgba(217, 119, 6, 0.4), 0 2px 4px rgba(217, 119, 6, 0.2);
      transform: translateY(-1px);
    }
  }

  &--default {
    background: linear-gradient(135deg, #ffffff 0%, #fafafa 100%);
    color: #262626;
    border: 1.5px solid #e5e5e5;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);

    &:not(:disabled):hover {
      background: linear-gradient(135deg, #f5f5f5 0%, #f0f0f0 100%);
      border-color: #d0d0d0;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
      transform: translateY(-1px);
    }
  }

  // Loading
  &--loading {
    pointer-events: none;
  }

  &__spinner {
    position: absolute;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  &__spinner-icon {
    width: 18px;
    height: 18px;
    animation: app-button-spin 0.75s linear infinite;
  }

  &__content {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    transition: opacity 0.15s ease;

    &--hidden {
      opacity: 0;
    }
  }
}

@keyframes app-button-spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}
</style>
