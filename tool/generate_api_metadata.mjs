import {readFile,writeFile,readdir} from 'node:fs/promises';
import {resolve,dirname} from 'node:path';import {fileURLToPath,pathToFileURL} from 'node:url';
const root=resolve(dirname(fileURLToPath(import.meta.url)),'..'),source=resolve(process.argv[2]);
const api=await import(pathToFileURL(resolve(source,'src/index.js')));
const dir=resolve(root,'lib/src');let dart=(await Promise.all((await readdir(dir)).filter(f=>f.endsWith('.dart')&&f!=='api_metadata.dart').map(f=>readFile(resolve(dir,f),'utf8')))).join('\n');
const camel=k=>k.toLowerCase().replace(/_([a-z0-9])/g,(_,c)=>c.toUpperCase());
const literal=v=>Array.isArray(v)?`[${v.map(literal).join(',')}]`:v&&typeof v==='object'?`{${Object.entries(v).map(([k,x])=>`${JSON.stringify(k)}:${literal(x)}`).join(',')}}`:JSON.stringify(v);
let out='// GENERATED from public JS metadata; do not edit. MPL-2.0.\n';const mapped={};
for(const [key,value] of Object.entries(api)) {
 if(!/^[A-Z][A-Z0-9_]+$/.test(key)) continue;
 const name=camel(key);
 // Existing typed constants/enums take precedence. Explicit map below records them.
 if(new RegExp('^const (?:[A-Za-z<>?, ]+ )?'+name+'\\s*=', 'm').test(dart)) {mapped[key]=name;continue;}
 out+=`const ${name} = ${literal(value)};\n`;mapped[key]=name;
}
await writeFile(resolve(dir,'api_metadata.dart'),out);
await writeFile(resolve(root,'tool/api-constant-map.json'),JSON.stringify(mapped,null,2)+'\n');

const names=Object.keys(api).map(key=>mapped[key]??key);
await writeFile(resolve(root,'tool/api_surface_check.dart'),
`// GENERATED public export compile check.
import 'package:ephemeris_lite/ephemeris_lite.dart';
void main() {final exports=<Object>[${names.join(',')}]; print('Public API entries: \${exports.length}');}
`);
// Update only the marked tables; preserve handwritten bilingual guides.
for (const [suffix, language] of [['', 'zh'], ['.en', 'en']]) {
  const file = resolve(root, `doc/api-map${suffix}.md`);
  const document = await readFile(file, 'utf8');
  const begin = '<!-- api-map:start -->';
  const end = '<!-- api-map:end -->';
  const start = document.indexOf(begin), finish = document.indexOf(end);
  if (start < 0 || finish < start || document.indexOf(begin, start + 1) >= 0) {
    throw new Error(`Missing or duplicate API table markers: ${file}`);
  }
  const zh = language === 'zh';
  const lines = Object.keys(api).map(key => {
    const kind = typeof api[key] === 'function'
      ? (zh ? 'Dart 函数／类型' : 'Dart function/type')
      : (zh ? '常量／元数据（参数类型见 API 文档）' : 'Constant/metadata; see typed API parameters');
    return `| \`${key}\` | \`${mapped[key] ?? key}\` | ${kind} |`;
  });
  const table = `| JS | Dart | ${zh ? '形式' : 'Kind'} |\n| --- | --- | --- |\n${lines.join('\n')}`;
  await writeFile(file, document.slice(0, start) + begin + '\n' + table + '\n' + document.slice(finish));
}
