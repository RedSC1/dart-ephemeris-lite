// Development-only JS fixtures; no JS runtime is used by the Dart library.
import {writeFile} from 'node:fs/promises';
import {resolve,dirname} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
const root=resolve(dirname(fileURLToPath(import.meta.url)),'..');
const source=resolve(process.argv[2]);
const c=await import(pathToFileURL(resolve(source,'src/chinese-calendar.js')));
const t=await import(pathToFileURL(resolve(source,'src/time.js')));
const windows=[], dates=[], instants=[], terms=[];
const years=[-6000,-3000,-720,-479,-456,-221,-220,-219,-105,-104,-103,0,9,10,23,237,238,239,689,690,700,701,761,762,1582,1900,2025,2026,2033,2034,3000,9999];
for(const year of years) {
 const options=year< -720 || year>3000?{mode:'china-astronomical'}:{};
 const jd=t.julianDay({year,month:6,day:1});
 const result=c.calculateChineseCalendarYear(jd,options);
 windows.push({jd,options,result});
 // Month boundaries, including exceptional names and reform month lengths.
 for(const m of result.months) {
 if(m.firstCivilDayNumber>=result.secondWinterSolsticeDayNumber) break;
 for(const offset of [0,m.dayCount-1]) {
 const {year,month,day}=t.calendarDateFromJulianDay(m.firstCivilDayNumber+offset-0.5);
 const date={year,month,day};
 let lunar;
 try {lunar=c.solarToLunar(date,options);} catch(error) {dates.push({date,options,error:error.message});continue;}
 let solar,reverseError;
 try {solar=c.lunarToSolar(lunar,options);} catch(error) {reverseError=error.message;}
 let monthDays,monthError;
 try {monthDays=c.getLunarMonthDays(lunar.year,lunar.month,lunar.isLeap,options);} catch(error) {monthError=error.message;}
 dates.push({date,options,lunar,solar,reverseError,monthDays,monthError});
 }
 }
}
for(const eventAccuracy of ['fast','mid','accurate']) {
 const options={mode:'china-astronomical',eventAccuracy};
 const jd=t.julianDay({year:2026,month:8,day:13});
 windows.push({jd,options,result:c.calculateChineseCalendarYear(jd,options)});
 for(let index=0;index<24;index++) terms.push({year:2026,index,options,result:c.getSpecificSolarTerm(2026,index,options)});
}
for(const utcOffsetMinutes of [-840,0,330,480,840]) for(const mode of ['historical','china-astronomical','local-astronomical']) {
 const options={mode,utcOffsetMinutes};
 for(const jd of [t.julianDay({year:2025,month:1,day:28,hour:16,minute:30}),t.julianDay({year:2026,month:8,day:12,hour:17,minute:40})]) {
 instants.push({jd,options,result:c.instantToLunar(jd,options)});
 }
}
for(const meridianDeg of [-180,82.5,180]) {
 const options={mode:'local-astronomical',dayBoundaryMode:'mean-solar-meridian',meridianDeg,utcOffsetMinutes:330};
 const jd=t.julianDay({year:2026,month:8,day:12,hour:17,minute:40});
 instants.push({jd,options,result:c.instantToLunar(jd,options)});
 windows.push({jd,options,result:c.calculateChineseCalendarYear(jd,options)});
}
const searches=[];
const probe=t.julianDay({year:2025,month:3,day:1,hour:4});
const boundary=c.findSolarTerm(probe,{filter:'jie'}).time.jdUT1;
for(const jd of [probe,boundary-1/86400,boundary,boundary+1/86400]) for(const direction of ['previous','next']) for(const filter of ['any','jie','qi']) {
 searches.push({jd,direction,filter,result:c.findSolarTerm(jd,{direction,filter})});
}
await writeFile(resolve(root,'test/fixtures/lunar.json'),JSON.stringify({windows,dates,instants,terms,searches})+'\n');
console.log(JSON.stringify({windows:windows.length,dates:dates.length,instants:instants.length,terms:terms.length,searches:searches.length}));
const sample=dates.filter((r,i)=>!r.error&&(i%10===0||r.lunar.monthName!==0));
let check=`// GENERATED JS fixtures for Dart VM and compiled JS.\nimport 'package:ephemeris_lite/ephemeris_lite.dart';\nvoid main() {\n`;
for(const r of sample) {
 const a=r.date,l=r.lunar;
 const mode=r.options.mode==='china-astronomical'?'chinaAstronomical':'historical';
 check+=`{\nfinal o=CalendarOptions(mode:CalendarMode.${mode});\nfinal a=solarToLunar(const CalendarDate(year:${a.year},month:${a.month},day:${a.day}),options:o);\n`;
 const fields=['year','historicalYear','month','day','isLeap','monthDays'];
 const comparisons=fields.map(k=>`a.${k} != ${l[k]}`).concat(`a.monthName.index != ${l.monthName}`);
 check+=`if(${comparisons.join(' || ')}) {throw StateError('Lunar conversion ${a.year}/${a.month}/${a.day}');}\n`;
 if(r.solar) check+=`final s=lunarToSolar(a,options:o);\nif(s.year!=${r.solar.year}||s.month!=${r.solar.month}||s.day!=${r.solar.day}) {throw StateError('Reverse conversion ${a.year}/${a.month}/${a.day}');}\n`;
 check+='}\n';
}
check+=`print('Passed ${sample.length} cross-runtime lunar cases.');\n}\n`;
await writeFile(resolve(root,'tool/lunar_check.dart'),check);
console.log('Cross-runtime lunar cases:',sample.length);
