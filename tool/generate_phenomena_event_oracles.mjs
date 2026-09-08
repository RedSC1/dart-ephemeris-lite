import {writeFile} from 'node:fs/promises';
import {resolve,dirname} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
const root=resolve(dirname(fileURLToPath(import.meta.url)),'..'),source=resolve(process.argv[2]);
const load=n=>import(pathToFileURL(resolve(source,'src',n)));
const p=await load('phenomena.js'),e=await load('event-search.js'),t=await load('time.js');
const phenomena=[],moons=[],events=[];
for(const jd of [1721059.5,2415020.5,2451545,2461041.5,2816787.5]) for(const frame of ['j2000','mean-of-date','true-of-date']) for(const accuracy of ['fast','mid','accurate']) {
 const options={frame,accuracy};
 for(const body of Object.keys(p.BODY_DISC_RADIUS_KM)) phenomena.push({body,jd,options,result:p.bodyPhenomena(body,jd,options)});
 moons.push({jd,options,result:p.moonIllumination(jd,options)});
}
for(let mask=0;mask<8;mask++) {
 const options={lightTime:!!(mask&1),aberration:!!(mask&2),solarDeflection:!!(mask&4)},jd=2461041.5;
 for(const body of ['moon','venus','saturn']) phenomena.push({body,jd,options,result:p.bodyPhenomena(body,jd,options)});
}
const jd=y=>t.julianDay({year:y,month:1,day:1});
function add(kind,body,start,end,extra={},options={}) {
 let result;
 if(kind==='longitude') result=e.searchLongitudeCrossings(body,extra.target,start,end,options);
 if(kind==='relative') result=e.searchRelativeLongitude(body,extra.other,extra.target,start,end,options);
 if(kind==='stations') result=e.searchStations(body,start,end,options);
 if(kind==='ingresses') result=e.searchIngresses(body,start,end,options);
 events.push({kind,body,start,end,extra,options,result});
}
for(const accuracy of ['fast','mid','accurate']) {
 const options={apparent:{accuracy}};
 add('stations','mercury',jd(2026),jd(2027),{},options);
 add('ingresses','mercury',jd(2026),jd(2027),{},options);
 add('relative','moon',jd(2026),jd(2026)+60,{other:'sun',target:180},options);
 add('longitude','sun',jd(2026),jd(2027),{target:360},options);
}
add('ingresses','mercury',jd(2025),jd(2026));
add('stations','venus',jd(2024),jd(2027));
add('stations','mars',jd(2025),jd(2026));
add('stations','jupiter',jd(2026),jd(2027));
add('relative','jupiter',jd(2026),jd(2027),{other:'sun',target:180});
add('ingresses','moon',jd(2026),jd(2026)+35);
add('longitude','mercury',jd(2026),jd(2027),{target:330},{apparent:{frame:'j2000'}});
add('longitude','sun',jd(2026),jd(2026),{target:0});
await writeFile(resolve(root,'test/fixtures/phenomena_events.json'),JSON.stringify({phenomena,moons,events})+'\n');
console.log({phenomena:phenomena.length,moons:moons.length,queries:events.length,events:events.reduce((n,r)=>n+r.result.length,0)});
