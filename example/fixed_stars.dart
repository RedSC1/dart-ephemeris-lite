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
