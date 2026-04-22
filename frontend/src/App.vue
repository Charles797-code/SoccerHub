<template>
  <el-config-provider :locale="zhCN">
    <router-view />
  </el-config-provider>
</template>

<script setup lang="ts">
import { ElConfigProvider } from 'element-plus'
import zhCN from 'element-plus/dist/locale/zh-cn.mjs'
</script>

<style>
html, body, #app {
  margin: 0;
  padding: 0;
  width: 100%;
  height: 100%;
}
</style>
