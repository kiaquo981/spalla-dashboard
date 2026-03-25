import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  build: {
    lib: {
      entry: 'src/index.tsx',
      name: 'OperonEditor',
      formats: ['iife'],
      fileName: () => 'operon-editor.umd.js',
    },
    cssFileName: 'operon-editor',
    rollupOptions: {
      output: {
        assetFileNames: 'operon-editor.[ext]',
      },
    },
    minify: 'esbuild',
    sourcemap: false,
  },
})
