import {readFile,writeFile} from 'node:fs/promises';
import {resolve,dirname} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
const root=resolve(dirname(fileURLToPath(import.meta.url)),'..'),source=resolve(process.argv[2]);
const load=f=>import(pathToFileURL(resolve(source,'src',f)));
const [s,e,t]=await Promise.all(['fixed-stars.js','eclipse-search.js','time.js'].map(load));
await writeFile(resolve(root,'test/fixtures/STARS_THIRD_PARTY_NOTICES.md'),await readFile(resolve(source,'packages/star-catalog/THIRD_PARTY_NOTICES.md')));
const bytes=await readFile(resolve(source,'packages/star-catalog/data/stars-bright-v5.tsc1'));
await writeFile(resolve(root,'test/fixtures/stars.tsc1'),bytes);
const catalog=s.parseTsc1Catalog(bytes),stars=[];
for(const key of ['sirius','vega','角宿一','hr_98','hr_4374','galactic_center_j2000']) for(const jd of [1356000.5,2451545,2460000.5,2810000.5]) {
 stars.push({kind:'icrf',key,jd,result:s.fixedStarIcrfState(catalog,key,jd)});
 for(const frame of ['j2000','mean-of-date','true-of-date']) for(const [aberration,solarDeflection] of [[true,true],[false,false],[true,false],[false,true]]) {
 const options={frame,aberration,solarDeflection};stars.push({kind:'state',key,jd,options,result:s.fixedStarState(catalog,key,jd,options)});
 }
}
const stringify=x=>JSON.stringify(x,(_,v)=>typeof v==='bigint'?v.toString():v);
await writeFile(resolve(root,'test/fixtures/fixed_stars.json'),stringify(stars)+'\n');
const jd=(y,m=1,d=1)=>t.julianDay({year:y,month:m,day:d}),solar=[];
for(const y of [-1000,1800,2000,2023,2024,2025,2026,2200,5000]) {
 const args=[jd(y),jd(y+1)];solar.push({kind:'search',args,result:e.searchSolarEclipses(...args)});
}
for(const args of [[2024,4,8],[2023,4,20],[2023,10,14],[2025,3,29],[2026,1,1]]) {
 const date=jd(...args);solar.push({kind:'details',args:[date],result:e.getSolarEclipseDetails(date)});
}
for(const [date,lon,lat] of [[jd(2024,4,8),-96.8,32.8],[jd(2024,4,8),116.4,39.9],[jd(2023,10,14),-106.65,35.08],[jd(2023,4,20),114.13,-22.39],[jd(2026,8,12),-3.7,40.4],[jd(2025,3,29),-74,40.7],[jd(2025,3,29),0,89]]) {
 const observer={longitudeDeg:lon,latitudeDeg:lat};solar.push({kind:'local',args:[date],observer,result:e.getLocalSolarEclipse(date,observer)});
}
await writeFile(resolve(root,'test/fixtures/solar_eclipses.json'),stringify(solar)+'\n');
await writeFile(resolve(root,'tool/remaining_portability_check.dart'),`// GENERATED; format with dart format.
import 'dart:convert';
import '../test/remaining_support.dart';
void main() {
 final catalog=parseTsc1Catalog(base64Decode('${bytes.toString('base64')}'));
 final stars=jsonDecode(r'''${stringify(stars.filter((_,i)=>i%7===0||i%17===0))}''') as List;
 for(final r in stars) {compareRemaining(runStar(catalog,r),r['result'],star:true);}
 final solar=jsonDecode(r'''${stringify([solar[3],solar[4],solar[5],solar[14],solar[15],solar[16],solar[18],solar[19]])}''') as List;
 for(final r in solar) {compareRemaining(runSolar(r),r['result']);}
 print('Fixed-star and solar-eclipse compiled JS checks passed');
}
`);
console.log({starQueries:stars.length,solarQueries:solar.length,solarEvents:solar.filter(r=>r.kind==='search').reduce((n,r)=>n+r.result.length,0)});
