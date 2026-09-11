# Test provenance and coverage audit

[中文](test-migration.md) | [English](test-migration.en.md) · [Documentation](README.en.md)

This audit compares the JS core, the former pure Dart library and the former Dart FFI wrapper. Scenarios are adapted to the new API rather than retaining old names, global state or FFI initialization. Porting the public API does not mean every old test passes unchanged.

Source versions, SHA-256 hashes and original titles are recorded in [`tool/test-sources.json`](../tool/test-sources.json). This is a source inventory, not proof that every original assertion was migrated. Generated comparisons and independent reference values are kept separate.

## Historical baseline: 2026-09-08

- Dart VM: 115 passed and one explicit skip for the PMO eclipse-width discrepancy below; scenarios were added to the previous 68-test suite.
- Static analysis passed; ten compiled-JavaScript regression groups were executed successfully.
- Handwritten runtime line coverage: 3,578 / 3,739, approximately 95.7%, excluding generated coefficients.
- JS baseline: 160 passed. Scenarios are grouped differently by language, so test counts are not directly comparable.

These are dated audit results, not a current test count. Later Hijri and module-splitting checks add coverage. Line coverage measures executed source lines, not scientific accuracy or completeness of scenarios.

## Validation layers

1. JS/Dart numeric comparisons test port consistency, not independent astronomical accuracy.
2. Python, C++, DE441 and SOFA controls in `test/fixtures/upstream/` retain source information and tolerances. Independent evaluation of the same coefficients is distinct from a DE441 control.
3. Legacy Dart PMO almanac/eclipse and calendar/time cases keep their independent expected values after API adaptation.
4. Structural and physical checks cover prefixes, counts, complete frequency envelopes, analytic derivatives, frames, boundaries and immutability.
5. Cross-platform regressions execute the compiled JavaScript; successful compilation alone is insufficient.

## JS suite mapping

| Source suite | Dart tests and focus |
| --- | --- |
| `ephemeris.test.js` | `port_test`, `api_completion_test`, `upstream_reference_test`, `upstream_model_contract_test`: three-tier states, independent model controls, former segment derivatives, VSOP87 controls, counts and prefixes |
| `apparent.test.js` | `apparent_test`, `upstream_physics_test`, `upstream_reference_test`: three frames, physical switches, light time, complete velocities and 81 C++ controls |
| `calendar-events.test.js` | `calendar_events_test`, `fast_events_test`, `accurate_events_test`, `api_completion_test`, `upstream_calendar_test`, `upstream_physics_test`: roots, cycle selection, latitude budgets, derivatives, 2026 DE441/PMO and solstice seconds |
| `chinese-calendar.test.js` | `chinese_calendar_test`, `historical_calendar_test`, `legacy_dart_test`: assigned dates, special names, 2033, reverse lookup, offsets, meridians and term boundaries |
| `chinese-era.test.js` | `chinese_era_test`: concurrent regimes, labels, exact transitions and source precision |
| `eclipses.test.js` | `upstream_eclipse_test`, `remaining_test`: grazing/noncentral/central types, local visibility and direct-geometry contacts |
| `eclipse-search.test.js` | `lunar_eclipses_test`, `remaining_test`, `upstream_eclipse_test`: enumeration, half-open boundaries, local visibility, empty and invalid requests |
| `event-search.test.js` | `event_search_test`, `upstream_reference_test`: scalar/angle roots, retrograde ingress, stations and complete independent enumerations |
| `fixed-stars.test.js` | `remaining_test`, `upstream_coordinates_stars_test`: TSC1, aliases, offset views, malformed input and independent C++ motion/rates |
| `ganzhi.test.js` | `ganzhi_test`, `legacy_dart_test`: sexagenary cycle, Nayin, pillars, term/hour boundaries and three Zi rules |
| `orbital-events.test.js` | `orbital_events_test`, `upstream_reference_test`: 297 independent C++ events, radial-rate roots, nodes, elongations and RA stations |
| `qi-shuo.test.js` | `qi_shuo_test`, `legacy_dart_test`: annual tables, arbitrary phases, pentads, offsets, historical assignment and 2026 phase counts |
| `sky-observation.test.js` | `phenomena_test`, `visibility_test`, `upstream_reference_test`: 45 independent physical triangles, horizontal coordinates, rise/set/transits |
| `solar-time.test.js` | `solar_time_test`, `ganzhi_test`, `upstream_physics_test`: C++/Swiss equation of time, solar clocks, day changes and pillars |
| `solar-visibility.test.js` | `visibility_test`, `upstream_physics_test`: independent Denver controls, limb/refraction behavior, polar and distant epochs |
| `time.test.js` | `port_test`, `upstream_model_contract_test`, `legacy_dart_test`: ΔT, first-derivative continuity, TT/UT1, dates and explicit offsets |

Dart test names in the table refer to files under `test/` with a `.dart` suffix.

Implementation-specific assertions cannot all be copied mechanically. Some mid value-only stages reuse state evaluators, so tests check public states, derivatives and final roots rather than cache layout or function identity. Private eclipse-interpolator residuals are not exposed directly; contacts are checked against frozen JS direct-3D-geometry roots, with the original 0.1 s solar and 0.03 s lunar tolerances. Those fixtures are not independent DE441 ephemerides.

Dart's type system replaces some JS invalid-string/missing-property tests. `tool/api_surface_check.dart` and portability programs exercise exports without restoring deleted APIs.

## Legacy pure Dart scenarios

The `sxwnl_spa_dart` tests contributed these scenarios:

- `astro_date_time_precision_test`: sub-millisecond times, UTC round trips and explicit offsets. Millisecond truncation was corrected. Modern double JD spacing is about 40 microseconds; tests use a 25-microsecond round-trip bound, not a nanosecond or all-epoch lossless guarantee.
- `moon_phase_search_test`: 50 principal phases and 99 eighth-phases in 2026, counts and ordering. Annual/half-open APIs replace old daily wrappers.
- `test_astronomical_yearing`: year −456, year-crossing months, −100 month sequences and Xin/Jingchu/Wu-Zhou reforms. Old string and pinyin parsers are outside this API.
- `test_v15_edge_cases`: previous/next inclusivity at exact terms, J2000, negative-year slots, cycles and Jie/Qi filters.
- `test_historical_solar_terms`: historical assigned dates during 1645–1700 can differ while actual event times remain unchanged.
- `pmo_2026_year_oracle_test`: 24 minute-resolution solar terms and 2026 lunar-month lengths, supplemented by original JS second-resolution DE441 controls.
- `test_calendar` / `test_models`: shared encoding, cycle, pillar/hour and calendar scenarios; not old DayInfo wrappers, string enums, class operators or default locations.
- `eclipse_test`: independent PMO controls plus modern classification/contact/visibility tests. Retired `ysPL/ecFast/msc/rsGS/rsPL/jieX`, old array layouts, NASA-radius switches and boundary drawing are not restored.
- `stars_test`: old `ephB/hxCalc/xingX` text tables/formatters are not ported; external TSC1 propagation uses independent C++ controls.
- Print-only `compare_*`, direct-term and historical debug scripts are not counted as automatic assertions. Their scenarios are covered by explicit tests; hardcoded local paths are not copied.
- Hijri scenarios from `test_hui_li_date` were added later. The old `testB2000` precession implementation is outside scope; independent C++/SOFA controls validate the current model without reverting it to pass old-model assertions.

## Legacy FFI scenarios

For `taiyin-dart/packages/ephemeris`, common time, Julian-day, Ganzhi, calendar, solar-clock, position, phenomena, visibility, orbital, eclipse and stellar behavior is covered by the above tests and frozen C++ controls. Three Julian-day controls from `ported/time_angle_interpolation_test.dart` were copied directly.

Native loading, handles, error codes, contexts, lifecycle, concurrency and optional-module routing do not apply to this non-FFI library. Split-JD nanoseconds, full TAI/UTC leap seconds, TDB/EOP tables, heliacal/occultation/astrology modules, Kaguya limb profiles and arbitrary SPK/OPM2 routing are outside lite scope. A single double JD must not be presented as native split-time precision.

The independent BaZi, Ziwei and Huangli rule suites belong to their own packages, not the ephemeris core.

## Unresolved independent reference discrepancy

`upstream_eclipse_test.dart` retains the PMO width control for the 2026-08-12 solar eclipse: 300.3 km with a 5 km tolerance. Both current JS and Dart return 285.2210251089675 km. Contacts (2 s), central coordinates, magnitude and duration pass their original controls.

The implementation describes its width as an instantaneous cross-section perpendicular to the ground track. Whether the reference uses the same definition still needs verification. Do not label the source wrong or claim a proven definition-only difference.

Only this assertion is explicitly skipped, with its original expected value and tolerance unchanged. It is not counted as passed. To reproduce the failure:

```sh
EPHEMERIS_CHECK_PMO_WIDTH=1 dart test test/upstream_eclipse_test.dart --name 'known discrepancy'
```

[Historical reverse-lookup limits](calendar-history.en.md) also remain documented rather than being redefined as a new standard.

## Running the checks

```sh
dart analyze
dart test
dart test --coverage=/tmp/ephemeris-coverage
dart compile js tool/test_regression_portability_check.dart -o /tmp/regressions.js
node /tmp/regressions.js
```

Coverage export produces raw coverage data. LCOV formatting additionally requires the optional `coverage` development tool; it is not a runtime dependency. The test fixtures, catalog and generators are excluded from pub archives.

Later Hijri checks include shared frozen samples, daily comparison and reverse conversion over five cycles, and execution after web compilation. They are additional to the dated baseline above.
