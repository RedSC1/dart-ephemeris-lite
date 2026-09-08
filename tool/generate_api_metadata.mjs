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
const lines=Object.keys(api).map(key=>`| \`${key}\` | \`${mapped[key]??key}\` | ${typeof api[key]==='function'?'Dart 函数／类型':'常量（枚举参数另有类型安全入口）'} |`);
await writeFile(resolve(root,'doc/api-map.md'),'# JS → Dart 公共 API 对照\n\n以 JS 根入口的 '+names.length+' 个导出为范围。Dart 使用命名参数、枚举、JulianTime 和不可变结果；名称对应不表示可直接复制 JS 调用语法。源码内部求值器不属于公共移植范围。\n\n| JS | Dart | 形式 |\n| --- | --- | --- |\n'+lines.join('\n')+'\n');
