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
    rollupOptions: {
      output: {
        assetFileNames: 'operon-editor.[ext]',
      },
    },
    minify: 'esbuild',
    sourcemap: false,
  },
})
