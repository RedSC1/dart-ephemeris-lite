# Fixed stars and TSC1 catalogs

[中文](fixed-stars.md) | [English](fixed-stars.en.md) · [Documentation](README.en.md)

## Runnable examples

[fixed_stars.dart](https://github.com/RedSC1/dart-ephemeris-lite/blob/main/example/fixed_stars.dart)

```sh
dart run example/fixed_stars.dart /path/to/catalog.tsc1
```

Replace the path with an actual TSC1 file. Catalog data is obtained separately and is not bundled with this package.

<!-- example: example/fixed_stars.dart -->
```dart
import 'dart:io';
import 'package:ephemeris_lite/ephemeris_lite.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart run example/fixed_stars.dart catalog.tsc1');
    return;
  }
  final catalog = parseTsc1Catalog(File(args.first).readAsBytesSync());
  print('Stars: ${catalog.starCount}; aliases: ${catalog.aliasCount}');
  print(fixedStarState(catalog, '角宿一', 2451545).toJson());
}
```

## Loading data

`parseTsc1Catalog(Uint8List)` and `Tsc1Catalog` read the C++-compatible TSC1 v1 format, including its header, 92-byte star records and 16-byte alias records. Full and lite catalogs use the same decoder. Loading does not apply a new magnitude cut or discard aliases.

The library performs no network or file I/O. Obtain the bytes in your application, then pass them to the parser. The CLI example below reads a file; a web application can pass downloaded bytes to the same parser. TSC1 files from the separate JS catalog package can be reused.

## Lookup and numeric representation

- Use `catalog.getStar(index)`, `catalog.find(alias)` or iteration. ASCII alias normalization matches C++; non-ASCII text is preserved. Alias hashes use 64-bit FNV-1a.
- Gaia IDs and hashes use `BigInt`, including on the web. The catalog owns an immutable copy of the input, so later buffer edits cannot corrupt its indexes.
- The decoder validates bounds, version, string termination and index ordering. Strings are decoded with strict UTF-8 validation.
- JSON represents Gaia IDs as decimal strings and missing non-finite catalog values as `null`.

## Propagation and apparent positions

`fixedStarIcrfState(catalog, key, jdTT)` propagates linear space motion, including proper motion, parallax and radial velocity. The key can be an alias, record index or catalog record. Without parallax, the implementation uses a direction carrier at 1e9 AU; that is not a measured distance.

`fixedStarPosition` and `fixedStarState` accept `FixedStarOptions`. The defaults use the true-of-date frame with aberration and solar deflection enabled. Finite-difference velocities include observer motion, corrections and changing frames. These interfaces do not have a planetary-series accuracy tier.

Vectors and result fields are read-only. Linear motion is not an N-body stellar orbit model; long-epoch propagation and missing measurements must be interpreted with the catalog's uncertainties.

## Catalog contents

The library does not prescribe how a catalog is filtered. The companion lite catalog contains bright stars, completion of traditional Chinese asterisms and zodiac line figures, and special direction records; it is not simply a `V ≤ 5` cut. Obtain the catalog separately because it is not bundled with this package.
