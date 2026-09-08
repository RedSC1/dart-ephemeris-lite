import {writeFile} from 'node:fs/promises';
import {resolve,dirname} from 'node:path';
import {pathToFileURL,fileURLToPath} from 'node:url';
const source=resolve(process.argv[2]??'../taiyin-lite');
const root=resolve(dirname(fileURLToPath(import.meta.url)),'..');
const core=await import(pathToFileURL(resolve(source,'src/index.js')));
const years=[-6000,-5999.75,-3000,-821,-820,-819.5,-720.001,-720,-719.9,-100,0,1000,1582,1800,1952.999,1953,2000,2015,2026,2027,2027.5,2028,2050,3000,8000,10000];
const deltaT=years.map(year=>({year,value:core.deltaTSeconds(year)}));
const dates=[[-6000,1,1],[0,2,29],[1582,10,4],[1582,10,15],[2000,1,1],[2026,6,21],[10000,12,31]];
const time=dates.map(([year,month,day])=>{
 const civil={year,month,day,hour:12,minute:34,second:56.789};
 const jd=core.julianDay(civil);
 return {civil,jd,roundtrip:core.calendarDateFromJulianDay(jd),decimalYear:core.decimalYearFromJulianDay(jd),instant:core.JulianTime.fromUT1(jd).toJSON()};
});
const states=[];
let seed=0x12345678;
const random=()=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed/2**32;};
const epochs=[-6000,-1000,0,1800,2000,2026,2200,3000,10000,...Array.from({length:32},()=>-6000+16000*random())].map(year=>2451545+(year-2000)*365.25);
for(const jd of epochs)for(const accuracy of ['fast','mid','accurate']){
 for(const body of ['mercury','venus','earth','mars','jupiter','saturn','uranus','neptune','moon']){
  const result=body==='moon'?core.moonState(jd,accuracy):core.planetHeliocentricState(body,jd,accuracy);
  states.push({jd,accuracy,body,...result});
 }
}
await writeFile(resolve(root,'test/fixtures/js_oracles.json'),JSON.stringify({deltaT,time,states})+'\n');
console.log(`${states.length} geometric states from JS, plus Delta-T and time fixtures.`);
