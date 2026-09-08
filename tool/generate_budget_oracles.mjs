import{writeFile}from'node:fs/promises';import{resolve,dirname}from'node:path';import{fileURLToPath,pathToFileURL}from'node:url';
const root=resolve(dirname(fileURLToPath(import.meta.url)),'..'),source=resolve(process.argv[2]);
const api=await import(pathToFileURL(resolve(source,'src/index.js')));const rows=[];
for(const jd of [1356000.5,2451545,2461000.5,2810000.5]) for(const budget of [0,10,30,277,'full']) {
 for(const solver of ['auto','safeguarded']) {rows.push({kind:'phase',jd,budget,solver,result:api.solveLunarPhase(Math.PI,jd,{moonLatitudeTerms:budget,solver}).toJSON?.()??api.solveLunarPhase(Math.PI,jd,{moonLatitudeTerms:budget,solver})});}
 for(const accuracy of ['fast','mid','accurate']) rows.push({kind:'direction',jd,budget,accuracy,result:api.moonDirectionState(jd,{accuracy,latitudeTerms:budget})});
}
await writeFile(resolve(root,'test/fixtures/budgets.json'),JSON.stringify(rows)+'\n');console.log(rows.length);
