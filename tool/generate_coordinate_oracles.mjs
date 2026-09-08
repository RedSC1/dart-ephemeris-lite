import {writeFile} from 'node:fs/promises';
import {resolve,dirname} from 'node:path';
import {pathToFileURL,fileURLToPath} from 'node:url';
const source=resolve(process.argv[2]??'../taiyin-lite');
const root=resolve(dirname(fileURLToPath(import.meta.url)),'..');
const c=await import(pathToFileURL(resolve(source,'src/coordinates.js')));
const years=Array.from({length:65},(_,i)=>-6000+250*i);
const rows=years.map(year=>{
 const jd=2451545+(year-2000)*365.25;
 return {jd,nutation:c.iau2000bNutationState(jd),nutation10:c.iau2000bNutationState(jd,10),
  precession:c.vondrak2011PrecessionMatrixState(jd),frame:c.meanEclipticOfDateMatrixState(jd),
  valueFrame:c.meanEclipticOfDateMatrix(jd),icrf:c.icrfEquatorialToJ2000Ecliptic([0.2,-0.5,0.8])};
});
await writeFile(resolve(root,'test/fixtures/js_coordinates.json'),JSON.stringify(rows)+'\n');
console.log(`${rows.length} coordinate epochs written.`);
