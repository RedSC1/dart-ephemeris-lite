# Scope and compatibility

[中文](port-status.md) | [English](port-status.en.md) · [Documentation](README.en.md)

The core public functionality of JS 1.0.0-rc.1 has been ported, with arithmetic Hijri support and subsequent Sun/Moon dependency splitting. All 202 root exports have Dart counterparts; `tool/api_surface_check.dart` compiles the list. See the [API map](api-map.en.md) for names, not interchangeable JS signatures.

## Implemented modules

| Area | Dart implementation |
| --- | --- |
| Accuracy | Typed tiers, no mutable global default; positions default accurate and calendar roots mid |
| Time | Julian days, hybrid calendars, ΔT, UT1/TT, JulianTime, ZonedTime and DateTime conversion |
| Hijri | Arithmetic forward/reverse conversion, explicit-offset day assignment, leap years and month lengths |
| Planets | Monomial series, offline prefixes, fixed rotation, geometric states and aliases |
| Moon | Full/prefix tiers, geocentric state/direction and raw model longitude |
| Pluto | Near model, coarse outer model and blending; no wide-range precision claim |
| Coordinates | Precession, nutation, date matrices, ICRF-to-J2000 transform and analytic rates |
| Apparent | Three frames, correction switches, complete-chain finite-difference velocities and read-only intermediate geometry |
| Calendar roots | Three nearest-event tiers, fast/accurate unwrapped roots, mid states/estimators and constrained latitude budgets |
| Chinese calendar | Historical day profiles, month sequence, special names, conversion and solar-term queries |
| Ganzhi | Encoding, Nayin, four pillars, whole-hour normalization, three Zi-hour rules and historical boundaries |
| Era names | 752 source records, concurrent candidates and boundary provenance/precision; inherited calendar limits |
| Annual tables | Solar terms, pentads and arbitrary phases, with physical and assigned dates separate |
| Visibility | Dedicated solar rise/set, horizontal coordinates, general rise/set/transits, refraction and polar states |
| Longitude events | Scalar/angle roots, longitude differences, stations and direct/retrograde ingresses |
| Lunar eclipses | Global search, maximum, contacts and local visibility |
| Solar eclipses | Global/local events, WGS84 cone geometry, ground contacts, width and duration; no map renderer |
| Fixed stars | External TSC1 v1, 64-bit IDs, aliases, space motion and apparent states |
| Orbital events | Lunar/Earth apsides, lunar nodes, Mercury/Venus elongations and RA events |
| Phenomena | Phase, illumination, lunar cycle, apparent diameter and horizontal parallax |
| Solar clocks | Mean/apparent solar time, equation of time, sidereal time and inverse clock conversion |

Generated tables and evaluators are separate. Lunar phase caches are local to an evaluation. Internal arbitrary-budget evaluators, retired JS implementations, map renderers and experimental build scripts are not public compatibility APIs. Catalog data remains external.

## Independent work and release criteria

Historical reverse-lookup ambiguities remain documented in [historical calendars](calendar-history.en.md). Matching an inherited result is not a correction of that result.

New `bazi_core` and `ziwei_core` consumers have integration regressions but remain separately versioned. The core and its consumers are published independently and pin their dependencies separately. Legacy application/data migration needs separate validation.

Dart-specific optimization and stable-release review are separate work. Some mid value-only stages reuse derivative evaluators, so equivalent numeric results do not imply identical JS work or performance.

A release must retain provenance hashes, avoid placeholder implementations and unexplained tolerance relaxation, and pass content review, analysis, tests and `dart pub publish --dry-run`. The current baseline is `1.0.0`; publication does not remove known limitations.

## Verification entry points

```sh
dart run example/main.dart
dart run tool/api_surface_check.dart
dart test
```

[Testing](test-migration.en.md) distinguishes JS comparisons, independent DE441/C++/SOFA controls and legacy PMO data. The shared 2026 eclipse-width discrepancy is not counted as passed.
