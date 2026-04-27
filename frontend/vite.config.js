import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';
import { resolve } from 'path';
import AutoImport from 'unplugin-auto-import/vite';
import Components from 'unplugin-vue-components/vite';
import { ElementPlusResolver } from 'unplugin-vue-components/resolvers';
export default defineConfig({
    plugins: [
        vue(),
        AutoImport({
            resolvers: [ElementPlusResolver()],
            imports: ['vue', 'vue-router', 'pinia'],
            dts: 'src/auto-imports.d.ts',
        }),
        Components({
            resolvers: [ElementPlusResolver()],
            dts: 'src/components.d.ts',
        }),
    ],
    resolve: {
        alias: {
            '@': resolve(__dirname, 'src'),
        },
    },
    server: {
        port: 3000,
        proxy: {
            '/uploads': {
                target: 'http://localhost:8080',
                changeOrigin: true,
            },
            '/api/uploads': {
                target: 'http://localhost:8080',
                changeOrigin: true,
                rewrite: function (path) { return path.replace(/^\/api\/uploads/, '/uploads'); },
            },
            '/api/upload': {
                target: 'http://localhost:8080',
                changeOrigin: true,
            },
            '/api': {
                target: 'http://localhost:8080',
                changeOrigin: true,
            },
            '/auth': {
                target: 'http://localhost:8080',
                changeOrigin: true,
            },
            '/social': {
                target: 'http://localhost:8080',
                changeOrigin: true,
            },
            '/follows': {
                target: 'http://localhost:8080',
                changeOrigin: true,
            },
            '/chat': {
                target: 'http://localhost:8080',
                changeOrigin: true,
            },
            '/admin': {
                target: 'http://localhost:8080',
                changeOrigin: true,
            },
            '/club-admin': {
                target: 'http://localhost:8080',
                changeOrigin: true,
            },
            '/stands': {
                target: 'http://localhost:8080',
                changeOrigin: true,
            },
            '/news': {
                target: 'http://localhost:8080',
                changeOrigin: true,
            },
            '/upload': {
                target: 'http://localhost:8080',
                changeOrigin: true,
            },
            '/analytics': {
                target: 'http://localhost:8080',
                changeOrigin: true,
            },
        },
    },
    build: {
        outDir: 'dist',
        sourcemap: false,
    },
});
