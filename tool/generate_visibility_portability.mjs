import {readFile,writeFile} from 'node:fs/promises';
import {resolve,dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
const root=resolve(dirname(fileURLToPath(import.meta.url)),'..');
const f=JSON.parse(await readFile(resolve(root,'test/fixtures/visibility.json'),'utf8'));
const days=f.days.filter((r,i)=>i%7===0||i===f.days.length-1),solar=f.solar.filter((r,i)=>i%13===0||i>=72);
const observer=o=>`Observer(longitudeDeg:${o.longitudeDeg},latitudeDeg:${o.latitudeDeg},heightMeters:${o.heightMeters??0})`;
const state=s=>({'not-found':'notFound','crosses':'crosses','always-above':'alwaysAbove','always-below':'alwaysBelow','tangent':'tangent'}[s]);
let code=`// GENERATED from JS visibility oracles.\nimport 'package:ephemeris_lite/ephemeris_lite.dart';\nvoid check(List<JulianTime> actual,List<double> expected) {\nif(actual.length!=expected.length) {throw StateError('Event count mismatch');}\nfor(var i=0;i<actual.length;i++) {if((actual[i].jdUT1-expected[i]).abs()*86400>=0.02) {throw StateError('Event time mismatch');}}\n}\nvoid main() {\n`;
for(const r of days) {
 const o=r.options;
 code+=`{final a=bodyRiseSetForDay(SkyBody.${r.body},${r.jd},${observer(r.observer)},options:BodyVisibilityOptions(limb:DiscLimb.${o.limb??'upper'},refraction:${o.refraction??true},horizonDegrees:${o.horizonDegrees??0},apparent:ApparentOptions(accuracy:Accuracy.${o.apparent?.accuracy??'accurate'})));\n`;
 code+=`if(a.altitudeState!=AltitudeState.${state(r.result.altitudeState)}) {throw StateError('Altitude state');}\n`;
 for(const field of ['rises','sets','upperTransits','lowerTransits']) code+=`check(a.${field},[${r.result[field].map(t=>t.jdUT1)}]);\n`;
 code+='}\n';
}
for(const r of solar) {
 const o=r.options;
 code+=`{final a=computeSolarRiseSetFast(${r.jd},${observer(r.observer)},options:SolarVisibilityOptions(limb:DiscLimb.${o.limb??'upper'},refraction:${o.refraction??true},horizonDegrees:${o.horizonDegrees??0},fixedDiscSize:${o.fixedDiscSize??false}));\n`;
 code+=`if(a.altitudeState!=AltitudeState.${state(r.result.altitudeState)}) {throw StateError('Solar state');}\n`;
 for(const field of ['rise','set']) code+=`check(a.${field}==null?[]:[a.${field}!],[${r.result[field]?.jdUT1??''}]);\n`;
 code+='}\n';
}
code+=`print('Passed ${days.length} body and ${solar.length} solar cross-runtime windows.');\n}\n`;
await writeFile(resolve(root,'tool/visibility_portability_check.dart'),code);
console.log({days:days.length,solar:solar.length});
