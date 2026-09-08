// Generate a no-dart:io check executable for both Dart VM and dart2js/Node.
import {readFile,writeFile} from 'node:fs/promises';
import {resolve,dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
const root=resolve(dirname(fileURLToPath(import.meta.url)),'..');
const {rows}=JSON.parse(await readFile(resolve(root,'test/fixtures/js_calendar_events.json')));
const sample=rows.filter((r,i)=>i%5===0);
const records=sample.map(r=>`(${r.near},${r.target},${r.lunar},Accuracy.${r.options.accuracy},EventSolver.${r.options.solver??'auto'},${r.result.jdTT})`).join(',\n');
await writeFile(resolve(root,'tool/portability_check.dart'),`// Generated from JS oracles; checks VM/dart2js numerical portability.\nimport 'package:ephemeris_lite/ephemeris_lite.dart';\nvoid main(){\nconst rows=<(double,double,bool,Accuracy,EventSolver,double)>[${records}];\nfor(final (near,target,lunar,accuracy,solver,expected) in rows){\nfinal result=lunar?solveLunarPhase(target,near,accuracy:accuracy,solver:solver):solveSolarLongitude(target,near,accuracy:accuracy,solver:solver);\nif((result.jdTT-expected).abs()>2e-8){throw StateError('Cross-runtime root mismatch: $near $lunar $accuracy');}\n}\nprint('Cross-runtime numerical check passed: ${sample.length} roots.');\n}\n`);
