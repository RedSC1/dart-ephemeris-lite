# JS → Dart public API map

[中文](api-map.md) | [English](api-map.en.md) · [Documentation](README.en.md)

Use this map to locate equivalent functionality, not as copyable signatures. Dart uses named parameters, typed enums and `JulianTime`; JS options objects cannot be passed unchanged. Internal evaluators are not public APIs.

For example, Dart calls `solveNewMoon(time.jdTT, accuracy: Accuracy.mid)`; see the complete [event example](qi-shuo-solar-time.en.md).

The current table has 202 entries, including arithmetic Hijri and pillar term-boundary helpers. The marked table is maintained by the metadata generator.

<!-- api-map:start -->
| JS | Dart | Kind |
| --- | --- | --- |
| `ACCURACY` | `accuracy` | Constant/metadata; see typed API parameters |
| `APPARENT_MODEL_INFO` | `apparentModelInfo` | Constant/metadata; see typed API parameters |
| `ARCSEC_TO_RAD` | `arcsecToRad` | Constant/metadata; see typed API parameters |
| `AU_KM` | `auKm` | Constant/metadata; see typed API parameters |
| `BODY_DISC_RADIUS_KM` | `bodyDiscRadiusKm` | Constant/metadata; see typed API parameters |
| `CALENDAR_DAY_BOUNDARY_MODE` | `calendarDayBoundaryMode` | Constant/metadata; see typed API parameters |
| `CALENDAR_MODE` | `calendarMode` | Constant/metadata; see typed API parameters |
| `DEFAULT_NEW_MOON_LATITUDE_TERMS` | `defaultNewMoonLatitudeTerms` | Constant/metadata; see typed API parameters |
| `DELTA_T_INFO` | `deltaTInfo` | Constant/metadata; see typed API parameters |
| `EARTHLY_BRANCHES` | `earthlyBranches` | Constant/metadata; see typed API parameters |
| `EARTH_MOON_MASS_RATIO` | `earthMoonMassRatio` | Constant/metadata; see typed API parameters |
| `ECLIPSE_SEARCH_INFO` | `eclipseSearchInfo` | Constant/metadata; see typed API parameters |
| `EPHEMERIS_FRAME_INFO` | `ephemerisFrameInfo` | Constant/metadata; see typed API parameters |
| `GANZHI_INFO` | `ganzhiInfo` | Constant/metadata; see typed API parameters |
| `HEAVENLY_STEMS` | `heavenlyStems` | Constant/metadata; see typed API parameters |
| `HISTORICAL_PROFILE_INFO` | `historicalProfileInfo` | Constant/metadata; see typed API parameters |
| `HONGXIAN_ERA_END_JD_EXCLUSIVE` | `hongxianEraEndJdExclusive` | Constant/metadata; see typed API parameters |
| `HONGXIAN_ERA_START_JD` | `hongxianEraStartJd` | Constant/metadata; see typed API parameters |
| `J2000` | `j2000` | Constant/metadata; see typed API parameters |
| `JulianTime` | `JulianTime` | Dart function/type |
| `LIGHT_TIME_DAYS_PER_AU` | `lightTimeDaysPerAu` | Constant/metadata; see typed API parameters |
| `LOW_MODEL_INFO` | `lowModelInfo` | Constant/metadata; see typed API parameters |
| `LUNAR_PHASE_NAMES` | `lunarPhaseNames` | Constant/metadata; see typed API parameters |
| `MODERN_CHINA_ERA_START_JD` | `modernChinaEraStartJd` | Constant/metadata; see typed API parameters |
| `MODERN_CHINA_ESTABLISHMENT_JD` | `modernChinaEstablishmentJd` | Constant/metadata; see typed API parameters |
| `MONTH_NAME` | `monthName` | Constant/metadata; see typed API parameters |
| `PILLAR_HISTORICAL_MODE` | `pillarHistoricalMode` | Constant/metadata; see typed API parameters |
| `PLANET` | `planet` | Constant/metadata; see typed API parameters |
| `PLUTO_MODEL_INFO` | `plutoModelInfo` | Constant/metadata; see typed API parameters |
| `QI_SHUO_INFO` | `qiShuoInfo` | Constant/metadata; see typed API parameters |
| `RAT_HOUR_MODE` | `ratHourMode` | Constant/metadata; see typed API parameters |
| `REPUBLIC_OF_CHINA_ERA_START_JD` | `republicOfChinaEraStartJd` | Constant/metadata; see typed API parameters |
| `SKY_BODIES` | `skyBodies` | Constant/metadata; see typed API parameters |
| `SKY_FRAME` | `skyFrame` | Constant/metadata; see typed API parameters |
| `SOLAR_ALTITUDE_STATE` | `solarAltitudeState` | Constant/metadata; see typed API parameters |
| `SOLAR_LIMB` | `solarLimb` | Constant/metadata; see typed API parameters |
| `SOLAR_TERM_NAMES` | `solarTermNames` | Constant/metadata; see typed API parameters |
| `SOLAR_TIME_INFO` | `solarTimeInfo` | Constant/metadata; see typed API parameters |
| `SOLAR_VISIBILITY_INFO` | `solarVisibilityInfo` | Constant/metadata; see typed API parameters |
| `SolarClock` | `SolarClock` | Dart function/type |
| `TIME_INFO` | `timeInfo` | Constant/metadata; see typed API parameters |
| `TSC1_ALIAS_RECORD_SIZE` | `tsc1AliasRecordSize` | Constant/metadata; see typed API parameters |
| `TSC1_ASTROMETRY_SOURCE` | `tsc1AstrometrySource` | Constant/metadata; see typed API parameters |
| `TSC1_HEADER_SIZE` | `tsc1HeaderSize` | Constant/metadata; see typed API parameters |
| `TSC1_STAR_FLAGS` | `tsc1StarFlags` | Constant/metadata; see typed API parameters |
| `TSC1_STAR_RECORD_SIZE` | `tsc1StarRecordSize` | Constant/metadata; see typed API parameters |
| `TSC1_VERSION` | `tsc1Version` | Constant/metadata; see typed API parameters |
| `Tsc1Catalog` | `Tsc1Catalog` | Dart function/type |
| `WUXING` | `wuxing` | Constant/metadata; see typed API parameters |
| `ZonedTime` | `ZonedTime` | Dart function/type |
| `advanceGanzhi` | `advanceGanzhi` | Dart function/type |
| `apparentBodyPosition` | `apparentBodyPosition` | Dart function/type |
| `apparentBodyState` | `apparentBodyState` | Dart function/type |
| `asUt1JulianDay` | `asUt1JulianDay` | Dart function/type |
| `bodyHorizontalPosition` | `bodyHorizontalPosition` | Dart function/type |
| `bodyPhenomena` | `bodyPhenomena` | Dart function/type |
| `bodyRiseSetForDay` | `bodyRiseSetForDay` | Dart function/type |
| `calculateChineseCalendarYear` | `calculateChineseCalendarYear` | Dart function/type |
| `calculateDayPillar` | `calculateDayPillar` | Dart function/type |
| `calculateFourPillars` | `calculateFourPillars` | Dart function/type |
| `calendarDateFromJulianDay` | `calendarDateFromJulianDay` | Dart function/type |
| `checkedAccuracy` | `checkedAccuracy` | Dart function/type |
| `civilDayNumber` | `civilDayNumber` | Dart function/type |
| `computeSolarRiseSetFast` | `computeSolarRiseSetFast` | Dart function/type |
| `decimalYearFromJulianDay` | `decimalYearFromJulianDay` | Dart function/type |
| `deltaTSeconds` | `deltaTSeconds` | Dart function/type |
| `deltaTSecondsFromTt` | `deltaTSecondsFromTt` | Dart function/type |
| `deltaTSecondsFromUt1` | `deltaTSecondsFromUt1` | Dart function/type |
| `describeFourPillars` | `describeFourPillars` | Dart function/type |
| `earthDirectionState` | `earthDirectionState` | Dart function/type |
| `earthHeliocentricPosition` | `earthHeliocentricPosition` | Dart function/type |
| `earthHeliocentricState` | `earthHeliocentricState` | Dart function/type |
| `earthPosition` | `earthPosition` | Dart function/type |
| `earthState` | `earthState` | Dart function/type |
| `elongationState` | `elongationState` | Dart function/type |
| `embHeliocentricPosition` | `embHeliocentricPosition` | Dart function/type |
| `embHeliocentricState` | `embHeliocentricState` | Dart function/type |
| `embPosition` | `embPosition` | Dart function/type |
| `embState` | `embState` | Dart function/type |
| `equationOfTime` | `equationOfTime` | Dart function/type |
| `findSolarTerm` | `findSolarTerm` | Dart function/type |
| `fixedStarIcrfState` | `fixedStarIcrfState` | Dart function/type |
| `fixedStarPosition` | `fixedStarPosition` | Dart function/type |
| `fixedStarState` | `fixedStarState` | Dart function/type |
| `fourPillarsForZonedTime` | `fourPillarsForZonedTime` | Dart function/type |
| `ganzhiBranch` | `ganzhiBranch` | Dart function/type |
| `ganzhiIndex` | `ganzhiIndex` | Dart function/type |
| `ganzhiName` | `ganzhiName` | Dart function/type |
| `ganzhiStem` | `ganzhiStem` | Dart function/type |
| `getChineseEraNames` | `getChineseEraNames` | Dart function/type |
| `getHourGanzhi` | `getHourGanzhi` | Dart function/type |
| `getLocalLunarEclipse` | `getLocalLunarEclipse` | Dart function/type |
| `getLocalSolarEclipse` | `getLocalSolarEclipse` | Dart function/type |
| `getLunarEclipseDetails` | `getLunarEclipseDetails` | Dart function/type |
| `getLunarMonthDays` | `getLunarMonthDays` | Dart function/type |
| `getMonthGanzhi` | `getMonthGanzhi` | Dart function/type |
| `getNayinElement` | `getNayinElement` | Dart function/type |
| `getNayinId` | `getNayinId` | Dart function/type |
| `getNextJie` | `getNextJie` | Dart function/type |
| `getNextQi` | `getNextQi` | Dart function/type |
| `getNextSolarTerm` | `getNextSolarTerm` | Dart function/type |
| `getPillarTermBoundary` | `getPillarTermBoundary` | Dart function/type |
| `getPreviousJie` | `getPreviousJie` | Dart function/type |
| `getPreviousPillarJie` | `getPreviousPillarJie` | Dart function/type |
| `getPreviousQi` | `getPreviousQi` | Dart function/type |
| `getPreviousSolarTerm` | `getPreviousSolarTerm` | Dart function/type |
| `getQiShuoYear` | `getQiShuoYear` | Dart function/type |
| `getSolarEclipseDetails` | `getSolarEclipseDetails` | Dart function/type |
| `getSpecificSolarTerm` | `getSpecificSolarTerm` | Dart function/type |
| `greenwichSiderealTime` | `greenwichSiderealTime` | Dart function/type |
| `hijriMonthDays` | `hijriMonthDays` | Dart function/type |
| `hijriToSolar` | `hijriToSolar` | Dart function/type |
| `historicalEventCivilDay` | `historicalEventCivilDay` | Dart function/type |
| `hybridAtmosphericRefraction` | `hybridAtmosphericRefraction` | Dart function/type |
| `iau2000bNutation` | `iau2000bNutation` | Dart function/type |
| `iau2000bNutationLongitude` | `iau2000bNutationLongitude` | Dart function/type |
| `iau2000bNutationState` | `iau2000bNutationState` | Dart function/type |
| `icrfEquatorialToJ2000Ecliptic` | `icrfEquatorialToJ2000Ecliptic` | Dart function/type |
| `instantToHijri` | `instantToHijri` | Dart function/type |
| `instantToLunar` | `instantToLunar` | Dart function/type |
| `isHijriLeapYear` | `isHijriLeapYear` | Dart function/type |
| `julianDay` | `julianDay` | Dart function/type |
| `jupiterHeliocentricPosition` | `jupiterHeliocentricPosition` | Dart function/type |
| `jupiterHeliocentricState` | `jupiterHeliocentricState` | Dart function/type |
| `localApparentSolarTime` | `localApparentSolarTime` | Dart function/type |
| `localApparentToMeanSolarTime` | `localApparentToMeanSolarTime` | Dart function/type |
| `localMeanSolarTime` | `localMeanSolarTime` | Dart function/type |
| `localMeanToApparentSolarTime` | `localMeanToApparentSolarTime` | Dart function/type |
| `lowElongationState` | `lowElongationState` | Dart function/type |
| `lowSolarLongitudeState` | `lowSolarLongitudeState` | Dart function/type |
| `lunarPhaseTimeAccurate` | `lunarPhaseTimeAccurate` | Dart function/type |
| `lunarPhaseTimeFast` | `lunarPhaseTimeFast` | Dart function/type |
| `lunarToSolar` | `lunarToSolar` | Dart function/type |
| `makeGanzhi` | `makeGanzhi` | Dart function/type |
| `marsHeliocentricPosition` | `marsHeliocentricPosition` | Dart function/type |
| `marsHeliocentricState` | `marsHeliocentricState` | Dart function/type |
| `meanEclipticOfDateMatrix` | `meanEclipticOfDateMatrix` | Dart function/type |
| `meanEclipticOfDateMatrixState` | `meanEclipticOfDateMatrixState` | Dart function/type |
| `meanObliquityIau2006` | `meanObliquityIau2006` | Dart function/type |
| `meanObliquityIau2006State` | `meanObliquityIau2006State` | Dart function/type |
| `meanSolarTime` | `meanSolarTime` | Dart function/type |
| `mercuryHeliocentricPosition` | `mercuryHeliocentricPosition` | Dart function/type |
| `mercuryHeliocentricState` | `mercuryHeliocentricState` | Dart function/type |
| `moonDirectionState` | `moonDirectionState` | Dart function/type |
| `moonElpLongitudeState` | `moonElpLongitudeState` | Dart function/type |
| `moonGeocentricPosition` | `moonGeocentricPosition` | Dart function/type |
| `moonGeocentricState` | `moonGeocentricState` | Dart function/type |
| `moonHeliocentricPosition` | `moonHeliocentricPosition` | Dart function/type |
| `moonHeliocentricState` | `moonHeliocentricState` | Dart function/type |
| `moonIllumination` | `moonIllumination` | Dart function/type |
| `moonLongitudeState` | `moonLongitudeState` | Dart function/type |
| `moonPosition` | `moonPosition` | Dart function/type |
| `moonState` | `moonState` | Dart function/type |
| `neptuneHeliocentricPosition` | `neptuneHeliocentricPosition` | Dart function/type |
| `neptuneHeliocentricState` | `neptuneHeliocentricState` | Dart function/type |
| `normalizeChartVirtualTime` | `normalizeChartVirtualTime` | Dart function/type |
| `normalizeTsc1Alias` | `normalizeTsc1Alias` | Dart function/type |
| `parseTsc1Catalog` | `parseTsc1Catalog` | Dart function/type |
| `planetGeocentricPosition` | `planetGeocentricPosition` | Dart function/type |
| `planetGeocentricState` | `planetGeocentricState` | Dart function/type |
| `planetHeliocentricPosition` | `planetHeliocentricPosition` | Dart function/type |
| `planetHeliocentricState` | `planetHeliocentricState` | Dart function/type |
| `plutoHeliocentricPosition` | `plutoHeliocentricPosition` | Dart function/type |
| `plutoHeliocentricState` | `plutoHeliocentricState` | Dart function/type |
| `saturnHeliocentricPosition` | `saturnHeliocentricPosition` | Dart function/type |
| `saturnHeliocentricState` | `saturnHeliocentricState` | Dart function/type |
| `searchAngleCrossings` | `searchAngleCrossings` | Dart function/type |
| `searchCrossings` | `searchCrossings` | Dart function/type |
| `searchEarthApsides` | `searchEarthApsides` | Dart function/type |
| `searchGreatestElongations` | `searchGreatestElongations` | Dart function/type |
| `searchIngresses` | `searchIngresses` | Dart function/type |
| `searchLongitudeCrossings` | `searchLongitudeCrossings` | Dart function/type |
| `searchLunarApsides` | `searchLunarApsides` | Dart function/type |
| `searchLunarEclipses` | `searchLunarEclipses` | Dart function/type |
| `searchLunarNodes` | `searchLunarNodes` | Dart function/type |
| `searchRelativeLongitude` | `searchRelativeLongitude` | Dart function/type |
| `searchRelativeRightAscension` | `searchRelativeRightAscension` | Dart function/type |
| `searchRightAscensionStations` | `searchRightAscensionStations` | Dart function/type |
| `searchSolarEclipses` | `searchSolarEclipses` | Dart function/type |
| `searchStations` | `searchStations` | Dart function/type |
| `solarAltitude` | `solarAltitude` | Dart function/type |
| `solarLongitudeState` | `solarLongitudeState` | Dart function/type |
| `solarLongitudeTimeAccurate` | `solarLongitudeTimeAccurate` | Dart function/type |
| `solarLongitudeTimeFast` | `solarLongitudeTimeFast` | Dart function/type |
| `solarRiseSetForDate` | `solarRiseSetForDate` | Dart function/type |
| `solarToHijri` | `solarToHijri` | Dart function/type |
| `solarToLunar` | `solarToLunar` | Dart function/type |
| `solveLunarPhase` | `solveLunarPhase` | Dart function/type |
| `solveNewMoon` | `solveNewMoon` | Dart function/type |
| `solveSolarLongitude` | `solveSolarLongitude` | Dart function/type |
| `sunGeocentricPosition` | `sunGeocentricPosition` | Dart function/type |
| `sunGeocentricState` | `sunGeocentricState` | Dart function/type |
| `trueSolarTime` | `trueSolarTime` | Dart function/type |
| `tsc1AliasHash` | `tsc1AliasHash` | Dart function/type |
| `ttToUt1` | `ttToUt1` | Dart function/type |
| `uranusHeliocentricPosition` | `uranusHeliocentricPosition` | Dart function/type |
| `uranusHeliocentricState` | `uranusHeliocentricState` | Dart function/type |
| `ut1ToTt` | `ut1ToTt` | Dart function/type |
| `venusHeliocentricPosition` | `venusHeliocentricPosition` | Dart function/type |
| `venusHeliocentricState` | `venusHeliocentricState` | Dart function/type |
| `vondrak2011PrecessionMatrix` | `vondrak2011PrecessionMatrix` | Dart function/type |
| `vondrak2011PrecessionMatrixState` | `vondrak2011PrecessionMatrixState` | Dart function/type |
<!-- api-map:end -->
