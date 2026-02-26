/**
 * PHOTO DIAGNOSTIC SCRIPT
 *
 * Executar no console do navegador para diagnosticar problemas de fotos:
 *
 * 1. Abra o DevTools (F12)
 * 2. Vá para a aba "Console"
 * 3. Copie e cole o conteúdo deste script
 * 4. Pressione Enter
 *
 * Irá listar:
 * - Todos os Instagram handles mapeados
 * - Fotos que faltam (foto: null)
 * - Verificação de URLs
 * - Problemas encontrados
 */

console.log('=== SPALLA PHOTO DIAGNOSTIC ===\n');

// 1. Listar todos os profiles
console.log('📊 INSTAGRAM_PROFILES Statistics:');
const profiles = Object.entries(INSTAGRAM_PROFILES);
console.log(`Total profiles: ${profiles.length}`);

// 2. Verificar fotos ausentes
const missingPhotos = profiles.filter(([_, p]) => !p.foto);
console.log(`\n⚠️  Profiles com FOTO AUSENTE (null): ${missingPhotos.length}`);
if (missingPhotos.length > 0) {
  missingPhotos.forEach(([handle, profile]) => {
    console.log(`  - ${handle}: "${profile.nome}"`);
  });
}

// 3. Verificar fotos com URLs externas (Instagram direto)
const externalPhotos = profiles.filter(([_, p]) => p.foto && p.foto.startsWith('http'));
console.log(`\n🌐 Profiles com FOTO EXTERNA (Instagram CDN): ${externalPhotos.length}`);
if (externalPhotos.length > 0) {
  externalPhotos.forEach(([handle, profile]) => {
    console.log(`  - ${handle}: "${profile.nome}"`);
    console.log(`    URL: ${profile.foto.substring(0, 80)}...`);
  });
}

// 4. Verificar fotos locais
const localPhotos = profiles.filter(([_, p]) => p.foto && p.foto.startsWith('photos/'));
console.log(`\n📁 Profiles com FOTO LOCAL: ${localPhotos.length}`);

// 5. Simular igPhoto() para alguns nomes
console.log('\n🧪 Testing igPhoto() function:');

const testCases = [
  'Letícia Ambrosano',
  'Amanda Ribeiro',
  'Erica Macedo',
  '@draamanda_ribeiro',
  '@dra.ericamacedo',
  'Letícia Oliveira'
];

testCases.forEach(input => {
  // Simulação do igPhoto logic
  const isHandle = !input.includes(' ');
  const handle = isHandle ? input.replace('@', '') : null;

  let result = null;
  let strategy = 'none';

  // Strategy 1: Exact
  if (handle && INSTAGRAM_PROFILES[handle]) {
    result = INSTAGRAM_PROFILES[handle].foto;
    strategy = 'exact';
  }
  // Strategy 2: Lowercase
  else if (handle) {
    const handleLower = handle.toLowerCase();
    if (INSTAGRAM_PROFILES[handleLower]) {
      result = INSTAGRAM_PROFILES[handleLower].foto;
      strategy = 'lowercase';
    }
  }
  // Strategy 3: Name search
  else if (!handle) {
    const nameLower = input.toLowerCase();
    for (const [key, profile] of Object.entries(INSTAGRAM_PROFILES)) {
      if (profile.nome && profile.nome.toLowerCase().includes(nameLower)) {
        result = profile.foto;
        strategy = 'name_search';
        break;
      }
    }
  }

  const status = result ? '✅' : '❌';
  console.log(`${status} "${input}" → ${strategy} → ${result || '(not found)'}`);
});

// 6. Análise de duplicatas
console.log('\n🔍 Verificando DUPLICATAS de FOTO:');
const photoMap = {};
let duplicates = 0;

profiles.forEach(([handle, profile]) => {
  if (profile.foto) {
    if (!photoMap[profile.foto]) {
      photoMap[profile.foto] = [];
    }
    photoMap[profile.foto].push(handle);
  }
});

Object.entries(photoMap).forEach(([foto, handles]) => {
  if (handles.length > 1) {
    console.log(`⚠️  FOTO DUPLICADA: ${foto}`);
    console.log(`   Handles: ${handles.join(', ')}`);
    duplicates++;
  }
});

if (duplicates === 0) {
  console.log('✅ Nenhuma foto duplicada encontrada');
}

// 7. Resumo final
console.log('\n📋 RESUMO:');
console.log(`✓ Total de profiles: ${profiles.length}`);
console.log(`✓ Com foto: ${localPhotos.length + externalPhotos.length}`);
console.log(`✗ Sem foto: ${missingPhotos.length}`);
console.log(`⚠️  Fotos duplicadas: ${duplicates}`);

console.log('\n💡 DICA: Se encontrar problemas, edite 12-APP-data.js para:');
console.log('  1. Adicionar "foto": "photos/[handle].jpg" para profiles sem foto');
console.log('  2. Remover/corrigir URLs duplicadas');
console.log('  3. Garantir que os handles correspondem aos nomes dos arquivos');
