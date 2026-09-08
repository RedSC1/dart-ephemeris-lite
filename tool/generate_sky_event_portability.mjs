import {readFile,writeFile} from 'node:fs/promises';
import {resolve,dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
const root=resolve(dirname(fileURLToPath(import.meta.url)),'..');
const f=JSON.parse(await readFile(resolve(root,'test/fixtures/phenomena_events.json'),'utf8'));
const rows=f.events.filter((r,i)=>i%3===0),phases=f.moons.filter((r,i)=>i%5===0);
const frame=s=>({'j2000':'j2000','mean-of-date':'meanOfDate','true-of-date':'trueOfDate'}[s]??'trueOfDate');
let code=`// GENERATED JS fixtures for browser/Node portability checks.\nimport 'package:ephemeris_lite/ephemeris_lite.dart';\nvoid main() {\n`;
for(const r of rows) {
 const o=r.options.apparent??{},opt=`ApparentOptions(accuracy:Accuracy.${o.accuracy??'accurate'},frame:SkyFrame.${frame(o.frame)})`;
 const body=`SkyBody.${r.body}`;
 let call;
 if(r.kind==='longitude')call=`searchLongitudeCrossings(${body},${r.extra.target},${r.start},${r.end},apparent:${opt})`;
 if(r.kind==='relative')call=`searchRelativeLongitude(${body},SkyBody.${r.extra.other},${r.extra.target},${r.start},${r.end},apparent:${opt})`;
 if(r.kind==='stations')call=`searchStations(${body},${r.start},${r.end},apparent:${opt})`;
 if(r.kind==='ingresses')call=`searchIngresses(${body},${r.start},${r.end},apparent:${opt})`;
 code+=`{final events=${call};\nif(${r.result.length===0?'events.isNotEmpty':`events.length!=${r.result.length}`}) {throw StateError('Event count');}\n`;
 for(const [i,e] of r.result.entries())code+=`if((events[${i}].time.jdTT-${e.time.jdTT}).abs()*86400>=0.1 || events[${i}].direction!=MotionDirection.${e.direction}) {throw StateError('Event epoch or direction');}\n`;
 code+='}\n';
}
for(const r of phases) {
 code+=`{final m=moonIllumination(${r.jd},options:ApparentOptions(accuracy:Accuracy.${r.options.accuracy},frame:SkyFrame.${frame(r.options.frame)}));\nif((m.phaseCycle-${r.result.phaseCycle}).abs()>1e-12 || m.waxing!=${r.result.waxing} || (m.illuminatedFraction!-${r.result.illuminatedFraction}).abs()>1e-12) {throw StateError('Moon phase');}}\n`;
}
code+=`print('Passed ${rows.length} sky searches and ${phases.length} moon phase cross-runtime cases.');\n}\n`;
await writeFile(resolve(root,'tool/sky_event_portability_check.dart'),code);
console.log({queries:rows.length,phases:phases.length});
