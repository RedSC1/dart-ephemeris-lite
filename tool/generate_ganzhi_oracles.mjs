import {writeFile} from 'node:fs/promises';
import {resolve,dirname} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
const root=resolve(dirname(fileURLToPath(import.meta.url)),'..'),source=resolve(process.argv[2]);
const load=n=>import(pathToFileURL(resolve(source,'src',n)));
const g=await load('ganzhi.js'),c=await load('chinese-calendar.js'),t=await load('time.js'),s=await load('solar-time.js');
const rows=[],normalizations=[];
const add=(jd,clock,options)=>rows.push({jd,clock,options,result:g.calculateFourPillars(jd,clock,options)});
for(const year of [-456,-104,0,690,1582,1900,2003,2026,3000]) {
 for(const hour of [0,11,22,23]) {
 const clock=new t.ZonedTime({year,month:3,day:13,hour,offsetMinutes:480});
 for(const ratHourMode of Object.values(g.RAT_HOUR_MODE)) add(clock.toJulianTime().jdUT1,clock,{ratHourMode});
 }
}
for(const year of [1900,2026]) for(const eventAccuracy of ['fast','mid','accurate']) for(const index of [21,23,1]) {
 const opts={mode:'china-astronomical',eventAccuracy};
 const term=c.getSpecificSolarTerm(year,index,opts);
 const assigned=c.historicalEventCivilDay('solarTerm',term.time.jdUT1);
 const points=[term.time.jdUT1];if(assigned!==null) points.push(assigned-0.5-480/1440);
 for(const boundary of points) for(const delta of [-0.5,0,0.5]) for(const pillarHistoricalMode of ['off','on','follow-calendar']) {
 const jd=boundary+delta/86400,clock=t.ZonedTime.fromJulianTime(jd,480);
 add(jd,clock,{...opts,pillarHistoricalMode});
 }
}
for(const hour of Array.from({length:25},(_,i)=>i)) {
 const midnight=t.julianDay({year:2026,month:4,day:8});
 for(const delta of [-0.001,0,0.001]) {
 const clock=t.calendarDateFromJulianDay(midnight+hour/24+delta/86400);
 normalizations.push({clock,result:g.normalizeChartVirtualTime(clock)});
 add(midnight+hour/24+delta/86400-480/1440,clock,{mode:'china-astronomical'});
 }
}
const before={year:2026,month:4,day:8,hour:10,minute:59,second:59.99998};
normalizations.push({clock:before,result:g.normalizeChartVirtualTime(before)});
const solar=[];
for(const kind of ['mean','apparent']) for(const delta of [-0.001,0,0.001]) {
 const local=t.julianDay({year:2003,month:3,day:13,hour:11})+delta/86400,longitude=118.5;
 const jd=(kind==='mean'?local:s.localApparentToMeanSolarTime(local,longitude))-longitude/360;
 const clock=(kind==='mean'?s.meanSolarTime:s.trueSolarTime)(jd,longitude);
 solar.push({kind,jd,longitude,result:g.calculateFourPillars(jd,clock,{mode:'china-astronomical'})});
}
await writeFile(resolve(root,'test/fixtures/ganzhi.json'),JSON.stringify({rows,normalizations,solar})+'\n');
console.log({pillars:rows.length,normalizations:normalizations.length,solar:solar.length});
