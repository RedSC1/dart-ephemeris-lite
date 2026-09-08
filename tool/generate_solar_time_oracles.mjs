import {writeFile} from 'node:fs/promises';
import {resolve,dirname} from 'node:path';
import {pathToFileURL,fileURLToPath} from 'node:url';
const source=resolve(process.argv[2]??'../taiyin-lite');
const root=resolve(dirname(fileURLToPath(import.meta.url)),'..');
const e=await import(pathToFileURL(resolve(source,'src/index.js')));
const rows=[];
for(const year of [-6000,0,1582,2000,2026,10000])for(const month of [1,3,6,9,12])for(const longitude of [-180,0,116.4074,180]){
 const time=new e.ZonedTime({year,month,day:1,hour:12,minute:30,second:15,offsetMinutes:480});
 rows.push({civil:time.toJSON(),longitude,eq:e.equationOfTime(time),mean:e.meanSolarTime(time,longitude).toJSON(),apparent:e.trueSolarTime(time,longitude).toJSON(),gast:e.greenwichSiderealTime(time.toJulianTime().jdUT1)});
}
await writeFile(resolve(root,'test/fixtures/js_solar_time.json'),JSON.stringify(rows)+'\n');
console.log(`${rows.length} solar-clock samples.`);
