import {writeFile} from 'node:fs/promises';
import {resolve,dirname} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
const root=resolve(dirname(fileURLToPath(import.meta.url)),'..'),source=resolve(process.argv[2]);
const load=n=>import(pathToFileURL(resolve(source,'src',n)));
const b=await load('body-visibility.js'),s=await load('solar-visibility.js'),t=await load('time.js');
const observers=[
 {longitudeDeg:116.4074,latitudeDeg:39.9042,heightMeters:50},
 {longitudeDeg:-104.9903,latitudeDeg:39.7392,heightMeters:1609},
 {longitudeDeg:18.9553,latitudeDeg:69.6492,heightMeters:10},
 {longitudeDeg:0,latitudeDeg:-80},
 {longitudeDeg:180,latitudeDeg:0},
 {longitudeDeg:-180,latitudeDeg:90},
];
const positions=[],solar=[],days=[],refraction=[];
for(const altitude of [-1.01,-1,-0.5,0,5,14,15,16,45,89,90]) for(const pressureMbar of [0,1010,850]) {
 const options={pressureMbar,temperatureCelsius:10};
 refraction.push({angle:altitude*Math.PI/180,options,value:s.hybridAtmosphericRefraction(altitude*Math.PI/180,options)});
}
const bodies=['sun','moon','mercury','venus','mars','jupiter','saturn','uranus','neptune','pluto'];
for(const observer of observers) for(const month of [3,6,12]) {
 const jd=t.julianDay({year:2026,month,day:21});
 for(const body of bodies) for(const accuracy of ['fast','mid','accurate']) {
 const options={apparent:{accuracy}};
 positions.push({body,jd,observer,options,result:b.bodyHorizontalPosition(body,jd,observer,options)});
 }
 for(const options of [{},{refraction:false,limb:'center'},{limb:'lower',fixedDiscSize:true},{horizonDegrees:-6,refraction:false}]) {
 solar.push({jd,observer,options,altitude:s.solarAltitude(jd,observer,options),result:s.computeSolarRiseSetFast(jd,observer,options)});
 }
 for(const body of ['sun','moon','venus']) {
 const options={};
 days.push({body,jd:jd-0.5,observer,options,result:b.bodyRiseSetForDay(body,jd-0.5,observer,options)});
 }
}
for(const year of [-6000,0,10000]) {
 const jd=t.julianDay({year,month:6,day:21}),observer=observers[0],options={};
 solar.push({jd,observer,options,altitude:s.solarAltitude(jd,observer,options),result:s.computeSolarRiseSetFast(jd,observer,options)});
}
for(const limb of ['upper','center','lower']) for(const refraction of [true,false]) {
 const body='moon',jd=2460409.5,observer=observers[0],options={limb,refraction,horizonDegrees:2,apparent:{accuracy:'mid'}};
 days.push({body,jd,observer,options,result:b.bodyRiseSetForDay(body,jd,observer,options)});
}
const grazing={body:'sun',jd:2460409.5,observer:{longitudeDeg:0,latitudeDeg:0},options:{refraction:false,limb:'center',horizonDegrees:82.411750263}};
let left=grazing.jd+0.4,right=grazing.jd+0.6;
const height=t=>b.bodyHorizontalPosition('sun',t,grazing.observer,{refraction:false}).geometricAltitudeDeg;
for(let i=0;i<60;i++){const x=left+(right-left)/3,y=right-(right-left)/3;if(height(x)<height(y))left=x;else right=y;}
grazing.options.horizonDegrees=height((left+right)/2)-1e-5;
grazing.result=b.bodyRiseSetForDay(grazing.body,grazing.jd,grazing.observer,grazing.options);days.push(grazing);
await writeFile(resolve(root,'test/fixtures/visibility.json'),JSON.stringify({positions,solar,days,refraction})+'\n');
console.log({positions:positions.length,solar:solar.length,days:days.length,refraction:refraction.length});
