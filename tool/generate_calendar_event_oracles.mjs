import {writeFile} from 'node:fs/promises';
import {resolve,dirname} from 'node:path';
import {pathToFileURL,fileURLToPath} from 'node:url';
const source=resolve(process.argv[2]??'../taiyin-lite');
const root=resolve(dirname(fileURLToPath(import.meta.url)),'..');
const e=await import(pathToFileURL(resolve(source,'src/index.js')));
const rows=[],states=[];
for(const year of [-5900,-1000,0,1582,2000,2026,3000,9900]){
 const near=2451545+(year-2000)*365.25+173.314;
 states.push({jd:near,solar:e.solarLongitudeState(near),moon:e.moonLongitudeState(near),elongation:e.elongationState(near),lowSolar:e.lowSolarLongitudeState(near),lowPhase:e.lowElongationState(near)});
 for(const accuracy of ['fast','mid','accurate'])for(const lunar of [false,true])for(const target of [0,Math.PI/2,Math.PI,3*Math.PI/2]){
  const options={accuracy};
  rows.push({near,target,lunar,options,result:(lunar?e.solveLunarPhase:e.solveSolarLongitude)(target,near,options).toJSON()});
 }
 for(const lunar of [false,true])for(const accuracy of ['mid','accurate']){
  const options={accuracy,solver:'safeguarded'};
  rows.push({near,target:0,lunar,options,result:(lunar?e.solveLunarPhase:e.solveSolarLongitude)(0,near,options).toJSON()});
 }
}
await writeFile(resolve(root,'test/fixtures/js_calendar_events.json'),JSON.stringify({rows,states})+'\n');
console.log(`${rows.length} nearest-event queries and ${states.length} state samples.`);
