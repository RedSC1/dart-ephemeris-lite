import {writeFile} from 'node:fs/promises';
import {resolve,dirname} from 'node:path';
import {pathToFileURL,fileURLToPath} from 'node:url';
const source=resolve(process.argv[2]??'../taiyin-lite');
const root=resolve(dirname(fileURLToPath(import.meta.url)),'..');
const e=await import(pathToFileURL(resolve(source,'src/calendar-events.js')));
const rows=[];
for(const year of [-5999,-4000,-2000,-1000,0,1000,1800,1900,2000,2026,2100,3000,6000,9999]){
 const t=(year-2000)/100;
 for(const lunar of [false,true]){
  const mean=lunar?7771.37714500204*t-1.08472:1.75347+Math.PI+628.3319653318*t;
  const steps=lunar?4:24;
  for(let i=0;i<steps;i++){
   const target=2*Math.PI*i/steps;
   const angle=target+2*Math.PI*Math.round((mean-target)/(2*Math.PI));
   rows.push({lunar,angle,jdTT:(lunar?e.lunarPhaseTimeFast:e.solarLongitudeTimeFast)(angle)});
  }
 }
}
await writeFile(resolve(root,'test/fixtures/js_fast_events.json'),JSON.stringify(rows)+'\n');
const accurate = rows.filter((row,index)=>index%7===0 || row.lunar).map(({lunar,angle})=>({lunar,angle,jdTT:(lunar?e.lunarPhaseTimeAccurate:e.solarLongitudeTimeAccurate)(angle)}));
await writeFile(resolve(root,'test/fixtures/js_accurate_events.json'),JSON.stringify(accurate)+'\n');
console.log(`${rows.length} fast event roots written.`);
