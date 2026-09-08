import {writeFile} from 'node:fs/promises';
import {resolve,dirname} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
const root=resolve(dirname(fileURLToPath(import.meta.url)),'..');
const source=resolve(process.argv[2]);
const {historicalEventCivilDay}=await import(pathToFileURL(resolve(source,'src/chinese-calendar.js')));
const {HISTORICAL_CALENDAR_DATA:h}=await import(pathToFileURL(resolve(source,'src/generated/historical-calendar-data.js')));
let output=`// GENERATED exhaustive JS parity cases; not an independent historical source.
// ignore_for_file: prefer_interpolation_to_compose_strings
import 'package:ephemeris_lite/ephemeris_lite.dart';
void checkHistoricalProfiles() {
`;
let count=0;
for(const [kind,solar] of [['solarTerm',true],['newMoon',false]]) {
 const p=h[kind], expected=[];
 for(let i=0;i<p.eventCount;i++) {
  const phase=p.firstPhaseIndex+i;
  const estimate=solar?(phase+0.5)/24*365.2422+2451259-7:(phase+0.5)*29.5306+2451551-14;
  expected.push(historicalEventCivilDay(kind,estimate));
 }
 output+=`{
 const expected = <int?>[${expected.join(',')}];
 for(var i=0;i<expected.length;i++) {
  final phase=${p.firstPhaseIndex}+i;
  final estimate=${solar?'(phase+0.5)/24*365.2422+2451259-7':'(phase+0.5)*29.5306+2451551-14'};
  final actual=historicalEventCivilDay(HistoricalEventKind.${kind},estimate);
  if(actual!=expected[i]) throw StateError('${kind} event $i: $actual != ' + expected[i].toString() + '');
 }
}
`;
 count+=expected.length;
}
output+=`}
void main() {
 checkHistoricalProfiles();
 print('Passed ${count} historical event assignments.');
}
`;
await writeFile(resolve(root,'tool/historical_check.dart'),output);
console.log(`Generated ${count} historical assignments`);
