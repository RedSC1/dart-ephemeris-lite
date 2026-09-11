# Development and data synchronization

[中文](development.md) | [English](development.en.md) · [Documentation](README.en.md)

## Documentation and local validation

Public APIs use `///` Dartdoc comments. Keep time scales, units, defaults, nullable results and boundary limits with the interface; distinguish position truncation from event-solving tiers.

```sh
dart pub get
dart doc --validate-links
dart analyze
dart test
dart run example/main.dart
```

Generated HTML starts at `doc/api/index.html` and is excluded by both `.gitignore` and `.pubignore`. Handwritten guides live in `doc/*.md`; Chinese files are the default and English files use `.en.md`. Keep paired pages and runnable examples synchronized. README links use absolute repository URLs so they also work on pub.dev and in Dartdoc. Link validation does not check external repository permissions.

## Regenerating source data

Normal library use and tests do not need a JS checkout. Regenerating coefficients and JS comparison fixtures requires Node.js and the same committed upstream checkout. Run from the repository root, replacing `../taiyin-lite` with its path:

```sh
node tool/import_js_data.mjs ../taiyin-lite
node tool/generate_oracles.mjs ../taiyin-lite
node tool/generate_coordinate_oracles.mjs ../taiyin-lite
node tool/generate_fast_event_oracles.mjs ../taiyin-lite
node tool/generate_apparent_oracles.mjs ../taiyin-lite
node tool/generate_calendar_event_oracles.mjs ../taiyin-lite
node tool/generate_solar_time_oracles.mjs ../taiyin-lite
node tool/generate_historical_oracles.mjs ../taiyin-lite
node tool/generate_qi_shuo_oracles.mjs ../taiyin-lite
node tool/generate_lunar_oracles.mjs ../taiyin-lite
node tool/generate_ganzhi_oracles.mjs ../taiyin-lite
node tool/generate_era_oracles.mjs ../taiyin-lite
node tool/generate_visibility_oracles.mjs ../taiyin-lite
node tool/generate_visibility_portability.mjs
node tool/generate_phenomena_event_oracles.mjs ../taiyin-lite
node tool/generate_sky_event_portability.mjs
dart format tool/sky_event_portability_check.dart
dart format tool/visibility_portability_check.dart
node tool/generate_calendar_portability.mjs
dart format tool/calendar_portability_check.dart
dart format tool/lunar_check.dart
node tool/generate_portability_check.mjs
dart format tool/portability_check.dart
dart pub get
dart test
dart analyze
```

Commit generated tables, fixtures and provenance together. `tool/upstream.json` records the source; the published copy is `doc/upstream.json`. Constants use round-trippable decimal doubles. Do not round frequencies, refit coefficients or reorder prefixes during a port; preserve Earth's tier-specific budgets. The split-table importer must remain enabled.

Fixtures use fixed seeds; tests do not require network access. Dart outputs are not used as JS expected values. Basic cross-language tolerances are 1e-11 AU and AU/day for planets, 1e-6 km and km/day for the Moon. These are implementation tolerances, not errors against observations or DE441.

## Scope and numerical checks

The package does not use FFI, embed a JS engine, depend on the legacy Dart core, silently replace models or publish higher-level chart rules. Runtime or memory parity with JS is not promised: some mid value-only stages also evaluate derivatives.

The following counts describe recorded fixture sets, not a claim about the current number of test cases:

| Area | Recorded coverage |
| --- | --- |
| Coordinates/Pluto | 65 coordinate epochs over −6000…10000, matrix derivatives/orthogonality; Pluto near/far boundaries at 1590/1600/2200/2210 and blend midpoints |
| Apparent/roots/clocks | All bodies, three frames/tiers and correction switches; wrapped and unwrapped roots, safeguarded solver, longitude endpoints, historical clocks and round trips; 45 root checks also executed as compiled JS |
| Historical profiles | All 85,485 profile event indexes checked on VM and compiled JS, with exact integer agreement; explicit 32-bit bitset arithmetic |
| Annual tables | 10 year/option sets, 598 events; reforms, phases, pentads, negative offsets, meridians; 2 ms event-time tolerance, exact dates/classification |
| Lunar calendar | 38 windows over −6000…9999, 846 dates, 33 instant conversions, 72 named-term and 24 adjacent-term queries; 102 reverse-lookup cases on compiled JS |
| Ganzhi/eras | 426 pillars, 76 clock normalizations, 6 solar-clock boundary cases; 173 era queries include a known throwing case; compiled JS checks 33 pillars, 76 clocks and 14 eras |
| Era data | 529 primary plus 223 supplementary records; per-query year-start caching, no global unbounded cache |
| Visibility | 540 horizontal positions, 75 solar samples/results, 61 day windows and 33 refraction samples; 10 general and 9 dedicated solar windows on compiled JS |
| Illumination/longitude | 474 phenomena and 45 lunar cycles; 20 search windows with 106 events, including retrograde re-entry and empty intervals; compiled JS checks 7 windows and 9 phases |
| Orbital events | 52 windows, 226 events at −1000/2000/2026/5000 and across frames/tiers; 11 windows on compiled JS |
| Lunar eclipses | 30 global queries across 9 years (20 eclipses), 5 single-full-moon and 16 local queries; 9 compiled-JS queries |
| Stars/solar eclipses | 312 stellar states and 21 solar-eclipse queries (20 global eclipses across 9 years plus local cases); full TSC1 fixture and attribution |
| Custom budgets | 100 cases over 0/10/30/277/full, both mid root solvers and three position tiers |

Historical reverse ambiguities and all integer labels remain explicit; do not weaken assertions to hide them. Geometry tests check physical extrema, node planes, station direction, contact ordering, immutable outputs and invalid arguments.

## Recorded cross-runtime tolerances

| Area | Thresholds |
| --- | --- |
| Rise/set | 0.02 s; horizontal coordinates 1e-8 degrees, dedicated solar altitude 1e-10 radians |
| Longitude events | 0.1 s; exact directions/boundaries/counts; illumination fraction 1e-12, disc/phase quantities 1e-7 in output units |
| Orbital events | 0.1 s, 1e-5 degrees, 0.001 km or 1e-10 AU, 1e-6 degrees/day |
| Lunar eclipses | 0.05 s, local angles 1e-4 degrees, magnitude-like quantities 1e-7 |
| Solar eclipses | 0.1 s, contact/greatest-eclipse positions 0.002 degrees, width 0.02 km; exact type/visibility |
| Fixed stars | Absolute plus relative position rounding; distant finite-difference velocity 1e-3 AU/day, angular speed 1e-7 degrees/day |

These thresholds are not observational accuracy claims. Local optimization and differencing can amplify floating-point path differences. Gaia IDs and 64-bit hashes must never pass through double.

## Reproducibility and publication

Domain generators include `generate_orbital_oracles.mjs`, `generate_lunar_eclipse_oracles.mjs`, `generate_remaining_oracles.mjs`, `generate_budget_oracles.mjs` and `generate_api_metadata.mjs`. Format generated Dart checker files after regeneration. Execute the `*_portability_check.dart` programs after compilation; compilation alone is not a runtime check. The metadata generator updates both language API tables.

`.pubignore` excludes tests, the fixture star catalog, tooling, plans and generated HTML. Run `dart pub publish --dry-run` before a release. Source metadata remains in `doc/upstream.json`; the core and its consumers are versioned separately. See [testing](test-migration.en.md) for independent references and unresolved discrepancies.
