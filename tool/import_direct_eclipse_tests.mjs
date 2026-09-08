// Freeze JS direct-geometry references, not the interpolated production results.
import {pathToFileURL} from 'node:url';
import {writeFileSync} from 'node:fs';
const root=process.argv[2];
if(!root) throw new Error('Usage: node tool/import_direct_eclipse_tests.mjs /path/to/taiyin-lite');
const load=name=>import(pathToFileURL(`${root}/src/${name}.js`));
const {solveSolarPolynomial}=await load('eclipse-solar');
const {solveSolar}=await load('eclipse-geometry');
const {coneDiscriminantFast}=await load('eclipse-cone');
const {solveLunar}=await load('eclipse-lunar');
const solar=[],lunar=[];
for(const k of [-80000,-11700,-804,283,300,600,42000,90000]) {
 const p=solveSolarPolynomial(k);if(!p)continue;
 const d=solveSolar(k,{seedTime:p.conjunction,cone:coneDiscriminantFast,greatestSteps:[.0625,1/1440,.25/1440,.0625/1440]});
 solar.push({k,kind:d.kind,maximum:d.maximum,contacts:d.contacts});
}
for(let k=270;k<305;k++) {
 const d=solveLunar(k,{directContacts:true});if(!d)continue;
 lunar.push({k,kind:d.kind,maximum:d.maximum,contacts:d.contacts});
}
writeFileSync('test/fixtures/upstream/direct-eclipses.json',JSON.stringify({source:'js-ephemeris-lite direct 3-D geometry (test/eclipses.test.js), not independent ephemeris data',solar,lunar},null,2)+'\n');
console.log({solar:solar.length,lunar:lunar.length});
