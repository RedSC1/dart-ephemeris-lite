import {readFile,writeFile} from 'node:fs/promises';
import {resolve,dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
const root=resolve(dirname(fileURLToPath(import.meta.url)),'..');
const g=JSON.parse(await readFile(resolve(root,'test/fixtures/ganzhi.json'),'utf8'));
const eras=JSON.parse(await readFile(resolve(root,'test/fixtures/eras.json'),'utf8')).filter((r,i)=>!r.error&&i%13===0);
const pillars=g.rows.filter((r,i)=>i%13===0);
let code=`// GENERATED from JS oracle fixtures.\nimport 'package:ephemeris_lite/ephemeris_lite.dart';\nvoid main() {\n`;
const clock=c=>`CalendarDate(year:${c.year},month:${c.month},day:${c.day},hour:${c.hour},minute:${c.minute},second:${c.second})`;
for(const row of pillars) {
 const o=row.options,mode=o.mode==='china-astronomical'?'chinaAstronomical':'historical';
 const rat={'next-day':'nextDay','current-day':'currentDay','current-day-tomorrow-stem':'currentDayTomorrowStem'}[o.ratHourMode]??'nextDay';
 const historical={'off':'off','on':'on','follow-calendar':'followCalendar'}[o.pillarHistoricalMode]??'followCalendar';
 code+=`{final a=calculateFourPillars(${row.jd},${clock(row.clock)},options:CalendarOptions(mode:CalendarMode.${mode},eventAccuracy:Accuracy.${o.eventAccuracy??'mid'}),ratHourMode:RatHourMode.${rat},pillarHistoricalMode:PillarHistoricalMode.${historical});\n`;
 code+=`if(${Object.entries(row.result).map(([k,v])=>`a.${k}!=${v}`).join('||')}) {throw StateError('Pillar parity');}}\n`;
}
for(const row of g.normalizations) {
 code+=`{final a=normalizeChartVirtualTime(${clock(row.clock)});\nif(${Object.entries(row.result).map(([k,v])=>`a.${k}!=${v}`).join('||')}) {throw StateError('Clock normalization parity');}}\n`;
}
for(const row of eras) {
 code+=`{final a=getChineseEraNames(${row.jd});\nif(a.length!=${row.result.length}) {throw StateError('Era count');}\n`;
 for(const [i,r] of row.result.entries()) {
 code+=`if(a[${i}].text!=${JSON.stringify(r.text)}||a[${i}].startJd!=${r.startJd}||a[${i}].endJdExclusive!=${r.endJdExclusive==='Infinity'?'double.infinity':r.endJdExclusive}) {throw StateError('Era boundary parity');}\n`;
 }
 code+='}\n';
}
code+=`print('Passed ${pillars.length} pillar, ${g.normalizations.length} clock, ${eras.length} era cross-runtime cases.');\n}\n`;
await writeFile(resolve(root,'tool/calendar_portability_check.dart'),code);
console.log({pillars:pillars.length,clocks:g.normalizations.length,eras:eras.length});
