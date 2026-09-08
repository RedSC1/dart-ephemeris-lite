import {writeFile} from 'node:fs/promises';
import {resolve,dirname} from 'node:path';
import {pathToFileURL,fileURLToPath} from 'node:url';
const source=resolve(process.argv[2]??'../taiyin-lite');
const root=resolve(dirname(fileURLToPath(import.meta.url)),'..');
const e=await import(pathToFileURL(resolve(source,'src/index.js')));
const pluto=[];
for(const year of [-6000,1589.99,1590,1595,1600,1600.01,2000,2199.99,2200,2205,2210,2210.01,10000]){
 for(const accuracy of ['fast','mid','accurate']){
 const jd=2451545+(year-2000)*365.25;
 pluto.push({jd,accuracy,...e.planetHeliocentricState('pluto',jd,accuracy)});
 }
}
const apparent=[];
for(const year of [-6000,1595,2000,2026,2205,10000])for(const body of e.SKY_BODIES){
 for(const frame of ['j2000','mean-of-date','true-of-date'])for(const accuracy of ['fast','mid','accurate']){
 const jd=2451545+(year-2000)*365.25;
 apparent.push({options:{frame,accuracy},...e.apparentBodyState(body,jd,{frame,accuracy})});
 }
}
for(const body of ['sun','moon','mercury'])for(const lightTime of [false,true])for(const aberration of [false,true])for(const solarDeflection of [false,true]){
 const options={lightTime,aberration,solarDeflection,accuracy:'accurate',frame:'true-of-date'};
 apparent.push({options,...e.apparentBodyState(body,2451545,options)});
}
await writeFile(resolve(root,'test/fixtures/js_apparent.json'),JSON.stringify({pluto,apparent})+'\n');
console.log(`${pluto.length} Pluto states and ${apparent.length} apparent states.`);
