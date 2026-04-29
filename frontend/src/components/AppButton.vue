<template>
  <button
    class="app-btn"
    :class="[`app-btn--${type}`, `app-btn--${size}`, { 'app-btn--loading': loading, 'app-btn--block': block }]"
    :disabled="disabled || loading"
    @click="$emit('click', $event)"
  >
    <span v-if="loading" class="app-btn__spinner">
      <svg class="app-btn__spinner-icon" viewBox="0 0 24 24" fill="none">
        <circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-dasharray="31.4 31.4" />
      </svg>
    </span>
    <span class="app-btn__content" :class="{ 'app-btn__content--hidden': loading }">
      <slot />
    </span>
  </button>
</template>

<script setup lang="ts">
defineProps<{
  type?: 'primary' | 'secondary' | 'ghost' | 'gold' | 'danger' | 'success'
  size?: 'sm' | 'md' | 'lg'
  loading?: boolean
  disabled?: boolean
  block?: boolean
}>()

defineEmits<{ click: [event: MouseEvent] }>()
</script>

<style scoped lang="scss">
@use '@/styles/tokens' as *;

// --------------------------------------------------------------------------
// Base Button
// --------------------------------------------------------------------------

.app-btn {
  position: relative;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: $space-2;
  font-family: $font-body;
  font-weight: $font-weight-semibold;
  border: none;
  border-radius: $radius-md;
  cursor: pointer;
  transition:
    background $duration-normal $ease-out,
    box-shadow $duration-normal $ease-out,
    transform $duration-fast $ease-spring,
    border-color $duration-fast $ease-out,
    opacity $duration-fast $ease-out;
  outline: none;
  white-space: nowrap;
  user-select: none;
  -webkit-tap-highlight-color: transparent;

  &:focus-visible {
    box-shadow:
      0 0 0 3px rgba($purple-primary, 0.35),
      0 0 0 5px rgba($purple-primary, 0.12);
  }

  &:disabled {
    cursor: not-allowed;
    opacity: 0.45;
    transform: none !important;
  }

  &:active:not(:disabled) {
    transform: scale(0.96);
    transition: transform 80ms $ease-in;
  }

  // --------------------------------------------------------------------------
  // Sizes
  // --------------------------------------------------------------------------

  &--sm {
    padding: $space-2 $space-4;
    font-size: $font-size-sm;
    border-radius: $radius-sm;
    gap: $space-1;
  }

  &--md {
    padding: $space-2 $space-5;
    font-size: $font-size-base;
  }

  &--lg {
    padding: $space-3 $space-6;
    font-size: $font-size-md;
    border-radius: $radius-lg;
  }

  // --------------------------------------------------------------------------
  // Block
  // --------------------------------------------------------------------------

  &--block {
    width: 100%;
  }

  // --------------------------------------------------------------------------
  // Primary (Purple gradient)
  // --------------------------------------------------------------------------

  &--primary {
    background: linear-gradient(135deg, $purple-primary 0%, rgba($purple-light, 0.9) 100%);
    color: $text-primary;
    box-shadow:
      0 2px 8px rgba($purple-primary, 0.3),
      0 0 0 1px rgba($purple-primary, 0.2) inset,
      0 1px 0 rgba(255, 255, 255, 0.1) inset;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.15);

    &:not(:disabled):hover {
      background: linear-gradient(135deg, $purple-hover 0%, rgba($purple-light, 0.95) 100%);
      box-shadow:
        0 4px 16px rgba($purple-primary, 0.4),
        0 0 0 1px rgba($purple-primary, 0.3) inset,
        0 1px 0 rgba(255, 255, 255, 0.15) inset;
      transform: translateY(-1px);
    }

    &:not(:disabled):active:not(:disabled) {
      box-shadow:
        0 1px 4px rgba($purple-primary, 0.3),
        0 0 0 1px rgba($purple-primary, 0.15) inset;
      transform: scale(0.96);
    }
  }

  // --------------------------------------------------------------------------
  // Secondary
  // --------------------------------------------------------------------------

  &--secondary {
    background: rgba($purple-primary, 0.1);
    color: $purple-light;
    border: 1.5px solid rgba($purple-primary, 0.3);
    box-shadow: none;

    &:not(:disabled):hover {
      background: rgba($purple-primary, 0.18);
      border-color: rgba($purple-primary, 0.5);
      color: $text-primary;
      transform: translateY(-1px);
    }
  }

  // --------------------------------------------------------------------------
  // Ghost
  // --------------------------------------------------------------------------

  &--ghost {
    background: rgba($surface-card, 0.5);
    color: $text-primary;
    border: 1.5px solid $border-default;
    backdrop-filter: blur(8px);

    &:not(:disabled):hover {
      background: rgba($surface-elevated, 0.8);
      border-color: rgba($purple-primary, 0.35);
      transform: translateY(-1px);
    }
  }

  // --------------------------------------------------------------------------
  // Gold
  // --------------------------------------------------------------------------

  &--gold {
    background: linear-gradient(135deg, $gold-bright 0%, $gold-dark 100%);
    color: $text-inverse;
    box-shadow:
      0 2px 8px rgba($gold-bright, 0.35),
      0 0 0 1px rgba($gold-bright, 0.2) inset;
    text-shadow: 0 1px 1px rgba(0, 0, 0, 0.1);

    &:not(:disabled):hover {
      background: linear-gradient(135deg, #fcd34d 0%, $gold-hover 100%);
      box-shadow:
        0 4px 16px rgba($gold-bright, 0.45),
        0 0 0 1px rgba($gold-bright, 0.25) inset;
      transform: translateY(-1px);
    }
  }

  // --------------------------------------------------------------------------
  // Danger
  // --------------------------------------------------------------------------

  &--danger {
    background: linear-gradient(135deg, $danger 0%, rgba($danger-light, 0.9) 100%);
    color: white;
    box-shadow:
      0 2px 8px rgba($danger, 0.3),
      0 0 0 1px rgba($danger, 0.15) inset;

    &:not(:disabled):hover {
      background: linear-gradient(135deg, $danger-hover 0%, rgba($danger-light, 0.95) 100%);
      box-shadow:
        0 4px 16px rgba($danger, 0.4),
        0 0 0 1px rgba($danger, 0.2) inset;
      transform: translateY(-1px);
    }
  }

  // --------------------------------------------------------------------------
  // Success
  // --------------------------------------------------------------------------

  &--success {
    background: linear-gradient(135deg, $success 0%, rgba($success-light, 0.9) 100%);
    color: white;
    box-shadow:
      0 2px 8px rgba($success, 0.3),
      0 0 0 1px rgba($success, 0.15) inset;

    &:not(:disabled):hover {
      background: linear-gradient(135deg, $success-hover 0%, rgba($success-light, 0.95) 100%);
      box-shadow:
        0 4px 16px rgba($success, 0.4),
        0 0 0 1px rgba($success, 0.2) inset;
      transform: translateY(-1px);
    }
  }

  // --------------------------------------------------------------------------
  // Loading
  // --------------------------------------------------------------------------

  &--loading {
    pointer-events: none;
  }
}

.app-btn__spinner {
  position: absolute;
  display: flex;
  align-items: center;
  justify-content: center;
}

.app-btn__spinner-icon {
  width: 16px;
  height: 16px;
  animation: app-btn-spin 0.75s linear infinite;
}

.app-btn__content {
  display: inline-flex;
  align-items: center;
  gap: $space-1;
  transition: opacity $duration-fast $ease-out;

  &--hidden {
    opacity: 0;
  }
}

@keyframes app-btn-spin {
  from { transform: rotate(0deg); }
  to   { transform: rotate(360deg); }
}

@media (prefers-reduced-motion: reduce) {
  .app-btn {
    transition: none;

    &:active:not(:disabled) {
      transform: none;
    }

    &:not(:disabled):hover {
      transform: none;
    }
  }

  .app-btn__spinner-icon {
    animation: none;
  }
}
</style>
