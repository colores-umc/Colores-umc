import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  site: 'https://colores-umc.github.io',
  base: '/Colores-umc',
  trailingSlash: 'ignore',
  vite: {
    plugins: [tailwindcss()],
  },
});
