import {writeFile} from 'node:fs/promises';
import {resolve,dirname} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
const root=resolve(dirname(fileURLToPath(import.meta.url)),'..'),source=resolve(process.argv[2]);
const load=n=>import(pathToFileURL(resolve(source,'src',n)));
const e=await load('chinese-era.js'),t=await load('time.js'),d=await load('generated/chinese-era-data.js');
const points=[];
for(const year of [-2000,-700,-456,-221,-220,-219,-104,0,23,220,237,238,265,420,581,618,690,700,701,762,907,947,960,1127,1279,1368,1644,1911,1912,1916,1949,2026]) points.push(t.julianDay({year,month:6,day:1}));
for(const key of ['MODERN_CHINA_ERA_START_JD','MODERN_CHINA_ESTABLISHMENT_JD','REPUBLIC_OF_CHINA_ERA_START_JD','HONGXIAN_ERA_START_JD','HONGXIAN_ERA_END_JD_EXCLUSIVE']) {
 for(const delta of [-1,0,1]) points.push(e[key]+delta/86400);
}
const records=[...d.CHINESE_ERA_RECORDS,...d.MANAKAI_SUPPLEMENTAL_ERA_RECORDS];
for(let i=0;i<records.length;i+=23) {
 const b=records[i][7],segments=Array.isArray(b)?b:b?.ddbc;
 const start=segments?.[0]?.[0]??b?.manakai?.[0],end=segments?.at(-1)?.[1]??b?.manakai?.[1];
 for(const jd of [start,end]) if(Number.isFinite(jd)) for(const delta of [-1,0,1]) points.push(jd+delta/86400);
}
const rows=[];
for(const jd of new Set(points)) {
 try {rows.push({jd,result:e.getChineseEraNames(jd)});}catch(error){rows.push({jd,error:error.message});}
}
await writeFile(resolve(root,'test/fixtures/eras.json'),JSON.stringify(rows,(_,v)=>v===Infinity?'Infinity':v)+'\n');
console.log('Era queries:',rows.length,'errors:',rows.filter(r=>r.error).length);
