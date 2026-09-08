// GENERATED from public JS metadata; do not edit. MPL-2.0.
const accuracy = {"FAST": "fast", "MID": "mid", "ACCURATE": "accurate"};
const apparentModelInfo = {
  "inputTimeScale": "TT",
  "angularUnit": "degree",
  "distanceUnit": "AU",
  "defaultFrame": "true-of-date",
  "frames": "j2000 / mean-of-date / true-of-date; J2000 is mean, not ICRS",
  "lightTime": "iterated heliocentric, TT used as TDB approximation",
  "aberration": "special-relativistic, heliocentric Earth velocity",
  "deflection": "Sun only, finite-distance, solar-limb limited",
  "shapiroDelay": false,
  "rates":
      "central difference of complete apparent position, 0.0005 day half-step",
  "limitations":
      "No barycentric solar reflex, EOP, multi-body deflection or planetary satellite photocentres; not a replacement for the full C++/DE441 pipeline.",
};
const calendarDayBoundaryMode = {
  "FIXED_UTC_OFFSET": "fixed-utc-offset",
  "MEAN_SOLAR_MERIDIAN": "mean-solar-meridian",
};
const calendarMode = {
  "HISTORICAL": "historical",
  "CHINA_ASTRONOMICAL": "china-astronomical",
  "LOCAL_ASTRONOMICAL": "local-astronomical",
};
const defaultNewMoonLatitudeTerms = 10;
const deltaTInfo = {
  "s15StartYear": -720,
  "earlyJoinStartYear": -820,
  "earlyJoin": "cubic Hermite, value and first derivative continuous",
  "annualStartYear": 1953,
  "annualEndYear": 2027,
  "futureFormulaStartYear": 2028,
  "futureModel":
      "SMH long-term baseline + 15-year cosine + 18.613-year nodal correction",
  "annualInterpolation": "Catmull-Rom cubic Hermite",
};
const ephemerisFrameInfo = {
  "frame": "J2000 mean/dynamical ecliptic and equinox",
  "geometric": true,
  "lightTimeApplied": false,
  "earthHeliocentricUnit": "AU",
  "planetHeliocentricUnit": "AU",
  "planetGeocentricUnit": "AU",
  "sunGeocentricUnit": "AU",
  "moonGeocentricUnit": "km",
  "moonHeliocentricUnit": "AU",
  "embHeliocentricUnit": "AU",
  "velocityTimeUnit": "day",
};
const ganzhiInfo = {
  "encoding": "high nibble=stem, low nibble=branch",
  "defaultRatHourMode": "next-day",
  "historicalTermBoundary": "assigned civil day 00:00 at UTC+08",
  "calendarModes": ["historical", "china-astronomical", "local-astronomical"],
  "calendarDayBoundaryModes": ["fixed-utc-offset", "mean-solar-meridian"],
};
const historicalProfileInfo = {
  "sha256": "61f195de0c39d86083ee85e090ea5d955e0ed81759d8f24d15cb9f4029975529",
  "profileEndJd": 2436935,
  "newMoonEvents": 33161,
  "solarTermEvents": 52324,
  "packedBitBytes": 3648,
};
const lowModelInfo = {
  "earthLongitudeTerms": [
    {
      "frequency": 0,
      "powers": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "serial": 0,
    },
    {
      "frequency": 0.392692240647076,
      "powers": [0],
      "serial": 1,
    },
    {
      "frequency": 6283.019821970057,
      "powers": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "serial": 2,
    },
    {
      "frequency": 0.8372779275435454,
      "powers": [0],
      "serial": 3,
    },
    {
      "frequency": 12566.060764690501,
      "powers": [0, 1, 2, 3, 4, 5, 6],
      "serial": 4,
    },
    {
      "frequency": 5753.384974286117,
      "powers": [0, 1],
      "serial": 5,
    },
    {
      "frequency": 3.402473996569303,
      "powers": [0, 1, 3],
      "serial": 6,
    },
    {
      "frequency": 77713.77290960068,
      "powers": [0, 1, 2, 3],
      "serial": 7,
    },
    {
      "frequency": 7860.418022739147,
      "powers": [0, 1, 3, 5],
      "serial": 8,
    },
    {
      "frequency": 0.26645250269537735,
      "powers": [2],
      "serial": 9,
    },
  ],
  "moonLongitudeTerms": [
    {"power": 0, "serial": 0},
    {"power": 0, "serial": 1},
    {"power": 0, "serial": 2},
    {"power": 0, "serial": 3},
    {"power": 0, "serial": 4},
    {"power": 0, "serial": 5},
    {"power": 0, "serial": 7},
    {"power": 0, "serial": 6},
    {"power": 0, "serial": 8},
    {"power": 0, "serial": 9},
  ],
  "earthRadiusTerms": [
    {
      "frequency": 6283.019828965289,
      "powers": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
      "serial": 0,
    },
    {
      "frequency": 0,
      "powers": [0, 1, 2, 3, 4, 5, 6, 7],
      "serial": 1,
    },
    {
      "frequency": 6282.863458543466,
      "powers": [4],
      "serial": 2,
    },
  ],
  "nutationTerms": 10,
};
const monthName = {
  "NORMAL": 0,
  "THIRTEEN": 1,
  "LATER_NINE": 2,
  "ALT_TWELVE": 3,
  "ALT_ONE": 4,
  "LATER_SAME_NAME": 5,
};
const pillarHistoricalMode = {
  "FOLLOW_CALENDAR": "follow-calendar",
  "OFF": "off",
  "ON": "on",
};
const planet = {
  "MERCURY": "mercury",
  "VENUS": "venus",
  "EARTH": "earth",
  "MARS": "mars",
  "JUPITER": "jupiter",
  "SATURN": "saturn",
  "URANUS": "uranus",
  "NEPTUNE": "neptune",
  "PLUTO": "pluto",
};
const plutoModelInfo = {
  "recommendedIntervalYears": [1600, 2200],
  "modelIntervalYears": [-6000, 10000],
  "transitionIntervalsYears": [
    [1590, 1600],
    [2200, 2210],
  ],
  "positionTarget": "Pluto-system barycenter",
  "warning":
      "Outside 1600..2200 results remain computable but are low accuracy, including event times. No accuracy claim outside -6000..10000.",
};
const qiShuoInfo = {
  "rangeStartYear": -6000,
  "rangeEndYear": 10000,
  "defaultUtcOffsetMinutes": 480,
  "defaultDayBoundaryMode": "fixed-utc-offset",
  "dayBoundaryModes": ["fixed-utc-offset", "mean-solar-meridian"],
  "civilCalendar": "hybrid Julian/Gregorian, switch at 1582-10-15",
};
const ratHourMode = {
  "NEXT_DAY": "next-day",
  "CURRENT_DAY": "current-day",
  "CURRENT_DAY_TOMORROW_STEM": "current-day-tomorrow-stem",
};
const skyBodies = [
  "sun",
  "moon",
  "mercury",
  "venus",
  "mars",
  "jupiter",
  "saturn",
  "uranus",
  "neptune",
  "pluto",
];
const skyFrame = {
  "J2000": "j2000",
  "MEAN_OF_DATE": "mean-of-date",
  "TRUE_OF_DATE": "true-of-date",
};
const solarAltitudeState = {
  "NOT_FOUND": "not-found",
  "CROSSES": "crosses",
  "ALWAYS_ABOVE": "always-above",
  "ALWAYS_BELOW": "always-below",
  "TANGENT": "tangent",
};
const solarLimb = {"UPPER": "upper", "CENTER": "center", "LOWER": "lower"};
const solarTimeInfo = {
  "longitudeConvention": "east-positive degrees",
  "meanDefinition": "LMT = UT1 + longitude / 360 degrees",
  "apparentDefinition": "LAT = LMT + equation of time",
  "clockIsVirtual": true,
};
const solarVisibilityInfo = {
  "ordinaryLatitudeLimitDeg": 65,
  "fallbackWindowStepHours": 2,
  "refractionModel": "C++ hybrid (Bennett/Smart blend)",
  "defaultLimb": "upper",
  "defaultRefraction": true,
};
const timeInfo = {
  "unixEpochJd": 2440587.5,
  "utcConvention": "UTC is treated as UT1 in the lite runtime",
  "civilCalendar": "hybrid Julian/Gregorian, switch at 1582-10-15",
};
const wuxing = {"WATER": 0, "WOOD": 1, "METAL": 2, "EARTH": 3, "FIRE": 4};
