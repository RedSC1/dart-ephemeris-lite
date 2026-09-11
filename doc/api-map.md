# JS → Dart 公共 API 对照

[中文](api-map.md) | [English](api-map.en.md) · [文档首页](README.md)

此表帮助定位同名功能，不是可直接复制的函数签名。Dart 使用命名参数、类型化枚举和 `JulianTime`；JS 的选项对象不能原样传入。源码内部求值器不属于公共 API。

例如气朔在 Dart 中写为 `solveNewMoon(time.jdTT, accuracy: Accuracy.mid)`；完整示例见[气朔与太阳时](qi-shuo-solar-time.md)。

当前表包含 202 项，包括算术回历及干支节气边界辅助接口；以下区域由元数据生成器维护。

<!-- api-map:start -->
| JS | Dart | 形式 |
| --- | --- | --- |
| `ACCURACY` | `accuracy` | 常量／元数据（参数类型见 API 文档） |
| `APPARENT_MODEL_INFO` | `apparentModelInfo` | 常量／元数据（参数类型见 API 文档） |
| `ARCSEC_TO_RAD` | `arcsecToRad` | 常量／元数据（参数类型见 API 文档） |
| `AU_KM` | `auKm` | 常量／元数据（参数类型见 API 文档） |
| `BODY_DISC_RADIUS_KM` | `bodyDiscRadiusKm` | 常量／元数据（参数类型见 API 文档） |
| `CALENDAR_DAY_BOUNDARY_MODE` | `calendarDayBoundaryMode` | 常量／元数据（参数类型见 API 文档） |
| `CALENDAR_MODE` | `calendarMode` | 常量／元数据（参数类型见 API 文档） |
| `DEFAULT_NEW_MOON_LATITUDE_TERMS` | `defaultNewMoonLatitudeTerms` | 常量／元数据（参数类型见 API 文档） |
| `DELTA_T_INFO` | `deltaTInfo` | 常量／元数据（参数类型见 API 文档） |
| `EARTHLY_BRANCHES` | `earthlyBranches` | 常量／元数据（参数类型见 API 文档） |
| `EARTH_MOON_MASS_RATIO` | `earthMoonMassRatio` | 常量／元数据（参数类型见 API 文档） |
| `ECLIPSE_SEARCH_INFO` | `eclipseSearchInfo` | 常量／元数据（参数类型见 API 文档） |
| `EPHEMERIS_FRAME_INFO` | `ephemerisFrameInfo` | 常量／元数据（参数类型见 API 文档） |
| `GANZHI_INFO` | `ganzhiInfo` | 常量／元数据（参数类型见 API 文档） |
| `HEAVENLY_STEMS` | `heavenlyStems` | 常量／元数据（参数类型见 API 文档） |
| `HISTORICAL_PROFILE_INFO` | `historicalProfileInfo` | 常量／元数据（参数类型见 API 文档） |
| `HONGXIAN_ERA_END_JD_EXCLUSIVE` | `hongxianEraEndJdExclusive` | 常量／元数据（参数类型见 API 文档） |
| `HONGXIAN_ERA_START_JD` | `hongxianEraStartJd` | 常量／元数据（参数类型见 API 文档） |
| `J2000` | `j2000` | 常量／元数据（参数类型见 API 文档） |
| `JulianTime` | `JulianTime` | Dart 函数／类型 |
| `LIGHT_TIME_DAYS_PER_AU` | `lightTimeDaysPerAu` | 常量／元数据（参数类型见 API 文档） |
| `LOW_MODEL_INFO` | `lowModelInfo` | 常量／元数据（参数类型见 API 文档） |
| `LUNAR_PHASE_NAMES` | `lunarPhaseNames` | 常量／元数据（参数类型见 API 文档） |
| `MODERN_CHINA_ERA_START_JD` | `modernChinaEraStartJd` | 常量／元数据（参数类型见 API 文档） |
| `MODERN_CHINA_ESTABLISHMENT_JD` | `modernChinaEstablishmentJd` | 常量／元数据（参数类型见 API 文档） |
| `MONTH_NAME` | `monthName` | 常量／元数据（参数类型见 API 文档） |
| `PILLAR_HISTORICAL_MODE` | `pillarHistoricalMode` | 常量／元数据（参数类型见 API 文档） |
| `PLANET` | `planet` | 常量／元数据（参数类型见 API 文档） |
| `PLUTO_MODEL_INFO` | `plutoModelInfo` | 常量／元数据（参数类型见 API 文档） |
| `QI_SHUO_INFO` | `qiShuoInfo` | 常量／元数据（参数类型见 API 文档） |
| `RAT_HOUR_MODE` | `ratHourMode` | 常量／元数据（参数类型见 API 文档） |
| `REPUBLIC_OF_CHINA_ERA_START_JD` | `republicOfChinaEraStartJd` | 常量／元数据（参数类型见 API 文档） |
| `SKY_BODIES` | `skyBodies` | 常量／元数据（参数类型见 API 文档） |
| `SKY_FRAME` | `skyFrame` | 常量／元数据（参数类型见 API 文档） |
| `SOLAR_ALTITUDE_STATE` | `solarAltitudeState` | 常量／元数据（参数类型见 API 文档） |
| `SOLAR_LIMB` | `solarLimb` | 常量／元数据（参数类型见 API 文档） |
| `SOLAR_TERM_NAMES` | `solarTermNames` | 常量／元数据（参数类型见 API 文档） |
| `SOLAR_TIME_INFO` | `solarTimeInfo` | 常量／元数据（参数类型见 API 文档） |
| `SOLAR_VISIBILITY_INFO` | `solarVisibilityInfo` | 常量／元数据（参数类型见 API 文档） |
| `SolarClock` | `SolarClock` | Dart 函数／类型 |
| `TIME_INFO` | `timeInfo` | 常量／元数据（参数类型见 API 文档） |
| `TSC1_ALIAS_RECORD_SIZE` | `tsc1AliasRecordSize` | 常量／元数据（参数类型见 API 文档） |
| `TSC1_ASTROMETRY_SOURCE` | `tsc1AstrometrySource` | 常量／元数据（参数类型见 API 文档） |
| `TSC1_HEADER_SIZE` | `tsc1HeaderSize` | 常量／元数据（参数类型见 API 文档） |
| `TSC1_STAR_FLAGS` | `tsc1StarFlags` | 常量／元数据（参数类型见 API 文档） |
| `TSC1_STAR_RECORD_SIZE` | `tsc1StarRecordSize` | 常量／元数据（参数类型见 API 文档） |
| `TSC1_VERSION` | `tsc1Version` | 常量／元数据（参数类型见 API 文档） |
| `Tsc1Catalog` | `Tsc1Catalog` | Dart 函数／类型 |
| `WUXING` | `wuxing` | 常量／元数据（参数类型见 API 文档） |
| `ZonedTime` | `ZonedTime` | Dart 函数／类型 |
| `advanceGanzhi` | `advanceGanzhi` | Dart 函数／类型 |
| `apparentBodyPosition` | `apparentBodyPosition` | Dart 函数／类型 |
| `apparentBodyState` | `apparentBodyState` | Dart 函数／类型 |
| `asUt1JulianDay` | `asUt1JulianDay` | Dart 函数／类型 |
| `bodyHorizontalPosition` | `bodyHorizontalPosition` | Dart 函数／类型 |
| `bodyPhenomena` | `bodyPhenomena` | Dart 函数／类型 |
| `bodyRiseSetForDay` | `bodyRiseSetForDay` | Dart 函数／类型 |
| `calculateChineseCalendarYear` | `calculateChineseCalendarYear` | Dart 函数／类型 |
| `calculateDayPillar` | `calculateDayPillar` | Dart 函数／类型 |
| `calculateFourPillars` | `calculateFourPillars` | Dart 函数／类型 |
| `calendarDateFromJulianDay` | `calendarDateFromJulianDay` | Dart 函数／类型 |
| `checkedAccuracy` | `checkedAccuracy` | Dart 函数／类型 |
| `civilDayNumber` | `civilDayNumber` | Dart 函数／类型 |
| `computeSolarRiseSetFast` | `computeSolarRiseSetFast` | Dart 函数／类型 |
| `decimalYearFromJulianDay` | `decimalYearFromJulianDay` | Dart 函数／类型 |
| `deltaTSeconds` | `deltaTSeconds` | Dart 函数／类型 |
| `deltaTSecondsFromTt` | `deltaTSecondsFromTt` | Dart 函数／类型 |
| `deltaTSecondsFromUt1` | `deltaTSecondsFromUt1` | Dart 函数／类型 |
| `describeFourPillars` | `describeFourPillars` | Dart 函数／类型 |
| `earthDirectionState` | `earthDirectionState` | Dart 函数／类型 |
| `earthHeliocentricPosition` | `earthHeliocentricPosition` | Dart 函数／类型 |
| `earthHeliocentricState` | `earthHeliocentricState` | Dart 函数／类型 |
| `earthPosition` | `earthPosition` | Dart 函数／类型 |
| `earthState` | `earthState` | Dart 函数／类型 |
| `elongationState` | `elongationState` | Dart 函数／类型 |
| `embHeliocentricPosition` | `embHeliocentricPosition` | Dart 函数／类型 |
| `embHeliocentricState` | `embHeliocentricState` | Dart 函数／类型 |
| `embPosition` | `embPosition` | Dart 函数／类型 |
| `embState` | `embState` | Dart 函数／类型 |
| `equationOfTime` | `equationOfTime` | Dart 函数／类型 |
| `findSolarTerm` | `findSolarTerm` | Dart 函数／类型 |
| `fixedStarIcrfState` | `fixedStarIcrfState` | Dart 函数／类型 |
| `fixedStarPosition` | `fixedStarPosition` | Dart 函数／类型 |
| `fixedStarState` | `fixedStarState` | Dart 函数／类型 |
| `fourPillarsForZonedTime` | `fourPillarsForZonedTime` | Dart 函数／类型 |
| `ganzhiBranch` | `ganzhiBranch` | Dart 函数／类型 |
| `ganzhiIndex` | `ganzhiIndex` | Dart 函数／类型 |
| `ganzhiName` | `ganzhiName` | Dart 函数／类型 |
| `ganzhiStem` | `ganzhiStem` | Dart 函数／类型 |
| `getChineseEraNames` | `getChineseEraNames` | Dart 函数／类型 |
| `getHourGanzhi` | `getHourGanzhi` | Dart 函数／类型 |
| `getLocalLunarEclipse` | `getLocalLunarEclipse` | Dart 函数／类型 |
| `getLocalSolarEclipse` | `getLocalSolarEclipse` | Dart 函数／类型 |
| `getLunarEclipseDetails` | `getLunarEclipseDetails` | Dart 函数／类型 |
| `getLunarMonthDays` | `getLunarMonthDays` | Dart 函数／类型 |
| `getMonthGanzhi` | `getMonthGanzhi` | Dart 函数／类型 |
| `getNayinElement` | `getNayinElement` | Dart 函数／类型 |
| `getNayinId` | `getNayinId` | Dart 函数／类型 |
| `getNextJie` | `getNextJie` | Dart 函数／类型 |
| `getNextQi` | `getNextQi` | Dart 函数／类型 |
| `getNextSolarTerm` | `getNextSolarTerm` | Dart 函数／类型 |
| `getPillarTermBoundary` | `getPillarTermBoundary` | Dart 函数／类型 |
| `getPreviousJie` | `getPreviousJie` | Dart 函数／类型 |
| `getPreviousPillarJie` | `getPreviousPillarJie` | Dart 函数／类型 |
| `getPreviousQi` | `getPreviousQi` | Dart 函数／类型 |
| `getPreviousSolarTerm` | `getPreviousSolarTerm` | Dart 函数／类型 |
| `getQiShuoYear` | `getQiShuoYear` | Dart 函数／类型 |
| `getSolarEclipseDetails` | `getSolarEclipseDetails` | Dart 函数／类型 |
| `getSpecificSolarTerm` | `getSpecificSolarTerm` | Dart 函数／类型 |
| `greenwichSiderealTime` | `greenwichSiderealTime` | Dart 函数／类型 |
| `hijriMonthDays` | `hijriMonthDays` | Dart 函数／类型 |
| `hijriToSolar` | `hijriToSolar` | Dart 函数／类型 |
| `historicalEventCivilDay` | `historicalEventCivilDay` | Dart 函数／类型 |
| `hybridAtmosphericRefraction` | `hybridAtmosphericRefraction` | Dart 函数／类型 |
| `iau2000bNutation` | `iau2000bNutation` | Dart 函数／类型 |
| `iau2000bNutationLongitude` | `iau2000bNutationLongitude` | Dart 函数／类型 |
| `iau2000bNutationState` | `iau2000bNutationState` | Dart 函数／类型 |
| `icrfEquatorialToJ2000Ecliptic` | `icrfEquatorialToJ2000Ecliptic` | Dart 函数／类型 |
| `instantToHijri` | `instantToHijri` | Dart 函数／类型 |
| `instantToLunar` | `instantToLunar` | Dart 函数／类型 |
| `isHijriLeapYear` | `isHijriLeapYear` | Dart 函数／类型 |
| `julianDay` | `julianDay` | Dart 函数／类型 |
| `jupiterHeliocentricPosition` | `jupiterHeliocentricPosition` | Dart 函数／类型 |
| `jupiterHeliocentricState` | `jupiterHeliocentricState` | Dart 函数／类型 |
| `localApparentSolarTime` | `localApparentSolarTime` | Dart 函数／类型 |
| `localApparentToMeanSolarTime` | `localApparentToMeanSolarTime` | Dart 函数／类型 |
| `localMeanSolarTime` | `localMeanSolarTime` | Dart 函数／类型 |
| `localMeanToApparentSolarTime` | `localMeanToApparentSolarTime` | Dart 函数／类型 |
| `lowElongationState` | `lowElongationState` | Dart 函数／类型 |
| `lowSolarLongitudeState` | `lowSolarLongitudeState` | Dart 函数／类型 |
| `lunarPhaseTimeAccurate` | `lunarPhaseTimeAccurate` | Dart 函数／类型 |
| `lunarPhaseTimeFast` | `lunarPhaseTimeFast` | Dart 函数／类型 |
| `lunarToSolar` | `lunarToSolar` | Dart 函数／类型 |
| `makeGanzhi` | `makeGanzhi` | Dart 函数／类型 |
| `marsHeliocentricPosition` | `marsHeliocentricPosition` | Dart 函数／类型 |
| `marsHeliocentricState` | `marsHeliocentricState` | Dart 函数／类型 |
| `meanEclipticOfDateMatrix` | `meanEclipticOfDateMatrix` | Dart 函数／类型 |
| `meanEclipticOfDateMatrixState` | `meanEclipticOfDateMatrixState` | Dart 函数／类型 |
| `meanObliquityIau2006` | `meanObliquityIau2006` | Dart 函数／类型 |
| `meanObliquityIau2006State` | `meanObliquityIau2006State` | Dart 函数／类型 |
| `meanSolarTime` | `meanSolarTime` | Dart 函数／类型 |
| `mercuryHeliocentricPosition` | `mercuryHeliocentricPosition` | Dart 函数／类型 |
| `mercuryHeliocentricState` | `mercuryHeliocentricState` | Dart 函数／类型 |
| `moonDirectionState` | `moonDirectionState` | Dart 函数／类型 |
| `moonElpLongitudeState` | `moonElpLongitudeState` | Dart 函数／类型 |
| `moonGeocentricPosition` | `moonGeocentricPosition` | Dart 函数／类型 |
| `moonGeocentricState` | `moonGeocentricState` | Dart 函数／类型 |
| `moonHeliocentricPosition` | `moonHeliocentricPosition` | Dart 函数／类型 |
| `moonHeliocentricState` | `moonHeliocentricState` | Dart 函数／类型 |
| `moonIllumination` | `moonIllumination` | Dart 函数／类型 |
| `moonLongitudeState` | `moonLongitudeState` | Dart 函数／类型 |
| `moonPosition` | `moonPosition` | Dart 函数／类型 |
| `moonState` | `moonState` | Dart 函数／类型 |
| `neptuneHeliocentricPosition` | `neptuneHeliocentricPosition` | Dart 函数／类型 |
| `neptuneHeliocentricState` | `neptuneHeliocentricState` | Dart 函数／类型 |
| `normalizeChartTime` | `normalizeChartTime` | Dart 函数／类型；旧名 `normalizeChartVirtualTime` 保留兼容 |
| `normalizeTsc1Alias` | `normalizeTsc1Alias` | Dart 函数／类型 |
| `parseTsc1Catalog` | `parseTsc1Catalog` | Dart 函数／类型 |
| `planetGeocentricPosition` | `planetGeocentricPosition` | Dart 函数／类型 |
| `planetGeocentricState` | `planetGeocentricState` | Dart 函数／类型 |
| `planetHeliocentricPosition` | `planetHeliocentricPosition` | Dart 函数／类型 |
| `planetHeliocentricState` | `planetHeliocentricState` | Dart 函数／类型 |
| `plutoHeliocentricPosition` | `plutoHeliocentricPosition` | Dart 函数／类型 |
| `plutoHeliocentricState` | `plutoHeliocentricState` | Dart 函数／类型 |
| `saturnHeliocentricPosition` | `saturnHeliocentricPosition` | Dart 函数／类型 |
| `saturnHeliocentricState` | `saturnHeliocentricState` | Dart 函数／类型 |
| `searchAngleCrossings` | `searchAngleCrossings` | Dart 函数／类型 |
| `searchCrossings` | `searchCrossings` | Dart 函数／类型 |
| `searchEarthApsides` | `searchEarthApsides` | Dart 函数／类型 |
| `searchGreatestElongations` | `searchGreatestElongations` | Dart 函数／类型 |
| `searchIngresses` | `searchIngresses` | Dart 函数／类型 |
| `searchLongitudeCrossings` | `searchLongitudeCrossings` | Dart 函数／类型 |
| `searchLunarApsides` | `searchLunarApsides` | Dart 函数／类型 |
| `searchLunarEclipses` | `searchLunarEclipses` | Dart 函数／类型 |
| `searchLunarNodes` | `searchLunarNodes` | Dart 函数／类型 |
| `searchRelativeLongitude` | `searchRelativeLongitude` | Dart 函数／类型 |
| `searchRelativeRightAscension` | `searchRelativeRightAscension` | Dart 函数／类型 |
| `searchRightAscensionStations` | `searchRightAscensionStations` | Dart 函数／类型 |
| `searchSolarEclipses` | `searchSolarEclipses` | Dart 函数／类型 |
| `searchStations` | `searchStations` | Dart 函数／类型 |
| `solarAltitude` | `solarAltitude` | Dart 函数／类型 |
| `solarLongitudeState` | `solarLongitudeState` | Dart 函数／类型 |
| `solarLongitudeTimeAccurate` | `solarLongitudeTimeAccurate` | Dart 函数／类型 |
| `solarLongitudeTimeFast` | `solarLongitudeTimeFast` | Dart 函数／类型 |
| `solarRiseSetForDate` | `solarRiseSetForDate` | Dart 函数／类型 |
| `solarToHijri` | `solarToHijri` | Dart 函数／类型 |
| `solarToLunar` | `solarToLunar` | Dart 函数／类型 |
| `solveLunarPhase` | `solveLunarPhase` | Dart 函数／类型 |
| `solveNewMoon` | `solveNewMoon` | Dart 函数／类型 |
| `solveSolarLongitude` | `solveSolarLongitude` | Dart 函数／类型 |
| `sunGeocentricPosition` | `sunGeocentricPosition` | Dart 函数／类型 |
| `sunGeocentricState` | `sunGeocentricState` | Dart 函数／类型 |
| `trueSolarTime` | `trueSolarTime` | Dart 函数／类型 |
| `tsc1AliasHash` | `tsc1AliasHash` | Dart 函数／类型 |
| `ttToUt1` | `ttToUt1` | Dart 函数／类型 |
| `uranusHeliocentricPosition` | `uranusHeliocentricPosition` | Dart 函数／类型 |
| `uranusHeliocentricState` | `uranusHeliocentricState` | Dart 函数／类型 |
| `ut1ToTt` | `ut1ToTt` | Dart 函数／类型 |
| `venusHeliocentricPosition` | `venusHeliocentricPosition` | Dart 函数／类型 |
| `venusHeliocentricState` | `venusHeliocentricState` | Dart 函数／类型 |
| `vondrak2011PrecessionMatrix` | `vondrak2011PrecessionMatrix` | Dart 函数／类型 |
| `vondrak2011PrecessionMatrixState` | `vondrak2011PrecessionMatrixState` | Dart 函数／类型 |
<!-- api-map:end -->
