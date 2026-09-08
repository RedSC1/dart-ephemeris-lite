import {writeFile} from 'node:fs/promises';
import {resolve,dirname} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
const root=resolve(dirname(fileURLToPath(import.meta.url)),'..');
const {getQiShuoYear}=await import(pathToFileURL(resolve(process.argv[2],'src/qi-shuo.js')));
const inputs=[
 ...['fast','mid','accurate'].map(eventAccuracy=>[2026,{eventAccuracy,lunarPhaseAnglesDeg:[0,90,180,270]}]),
 [-220,{includePentads:true}],
 [689,{lunarPhaseAnglesDeg:[0,90]}],
 [1582,{}],
 [1900,{mode:'china-astronomical',utcOffsetMinutes:-300}],
 [1900,{mode:'historical',utcOffsetMinutes:-300}],
 [2026,{mode:'local-astronomical',utcOffsetMinutes:-840,dayBoundaryMode:'mean-solar-meridian',meridianDeg:180,lunarPhaseAnglesDeg:[-90,0,360,45.123456789]}],
 [2000,{includeSolarTerms:false,includePentads:true,lunarPhaseAnglesDeg:[]}],
];
const rows=inputs.map(([year,options])=>({year,options,result:getQiShuoYear(year,options)}));
await writeFile(resolve(root,'test/fixtures/qi_shuo.json'),JSON.stringify(rows)+'\n');
console.log('Generated', rows.reduce((sum,r)=>sum+r.result.events.length,0),'events across',rows.length,'years/options');
