// GENERATED JS fixtures for browser/Node portability checks.
import 'package:ephemeris_lite/ephemeris_lite.dart';

void main() {
  {
    final events = searchStations(
      SkyBody.mercury,
      2461041.5,
      2461406.5,
      apparent: ApparentOptions(
        accuracy: Accuracy.fast,
        frame: SkyFrame.trueOfDate,
      ),
    );
    if (events.length != 6) {
      throw StateError('Event count');
    }
    if ((events[0].time.jdTT - 2461097.7841953747).abs() * 86400 >= 0.1 ||
        events[0].direction != MotionDirection.retrograde) {
      throw StateError('Event epoch or direction');
    }
    if ((events[1].time.jdTT - 2461120.315216806).abs() * 86400 >= 0.1 ||
        events[1].direction != MotionDirection.direct) {
      throw StateError('Event epoch or direction');
    }
    if ((events[2].time.jdTT - 2461221.234158065).abs() * 86400 >= 0.1 ||
        events[2].direction != MotionDirection.retrograde) {
      throw StateError('Event epoch or direction');
    }
    if ((events[3].time.jdTT - 2461245.4575386904).abs() * 86400 >= 0.1 ||
        events[3].direction != MotionDirection.direct) {
      throw StateError('Event epoch or direction');
    }
    if ((events[4].time.jdTT - 2461337.8013581596).abs() * 86400 >= 0.1 ||
        events[4].direction != MotionDirection.retrograde) {
      throw StateError('Event epoch or direction');
    }
    if ((events[5].time.jdTT - 2461358.163211394).abs() * 86400 >= 0.1 ||
        events[5].direction != MotionDirection.direct) {
      throw StateError('Event epoch or direction');
    }
  }
  {
    final events = searchLongitudeCrossings(
      SkyBody.sun,
      360,
      2461041.5,
      2461406.5,
      apparent: ApparentOptions(
        accuracy: Accuracy.fast,
        frame: SkyFrame.trueOfDate,
      ),
    );
    if (events.length != 1) {
      throw StateError('Event count');
    }
    if ((events[0].time.jdTT - 2461120.116019357).abs() * 86400 >= 0.1 ||
        events[0].direction != MotionDirection.direct) {
      throw StateError('Event epoch or direction');
    }
  }
  {
    final events = searchRelativeLongitude(
      SkyBody.moon,
      SkyBody.sun,
      180,
      2461041.5,
      2461101.5,
      apparent: ApparentOptions(
        accuracy: Accuracy.mid,
        frame: SkyFrame.trueOfDate,
      ),
    );
    if (events.length != 2) {
      throw StateError('Event count');
    }
    if ((events[0].time.jdTT - 2461043.919493463).abs() * 86400 >= 0.1 ||
        events[0].direction != MotionDirection.direct) {
      throw StateError('Event epoch or direction');
    }
    if ((events[1].time.jdTT - 2461073.4238973223).abs() * 86400 >= 0.1 ||
        events[1].direction != MotionDirection.direct) {
      throw StateError('Event epoch or direction');
    }
  }
  {
    final events = searchIngresses(
      SkyBody.mercury,
      2461041.5,
      2461406.5,
      apparent: ApparentOptions(
        accuracy: Accuracy.accurate,
        frame: SkyFrame.trueOfDate,
      ),
    );
    if (events.length != 13) {
      throw StateError('Event count');
    }
    if ((events[0].time.jdTT - 2461042.383229766).abs() * 86400 >= 0.1 ||
        events[0].direction != MotionDirection.direct) {
      throw StateError('Event epoch or direction');
    }
    if ((events[1].time.jdTT - 2461061.196064476).abs() * 86400 >= 0.1 ||
        events[1].direction != MotionDirection.direct) {
      throw StateError('Event epoch or direction');
    }
    if ((events[2].time.jdTT - 2461078.450843755).abs() * 86400 >= 0.1 ||
        events[2].direction != MotionDirection.direct) {
      throw StateError('Event epoch or direction');
    }
    if ((events[3].time.jdTT - 2461145.6407234855).abs() * 86400 >= 0.1 ||
        events[3].direction != MotionDirection.direct) {
      throw StateError('Event epoch or direction');
    }
    if ((events[4].time.jdTT - 2461163.623668637).abs() * 86400 >= 0.1 ||
        events[4].direction != MotionDirection.direct) {
      throw StateError('Event epoch or direction');
    }
    if ((events[5].time.jdTT - 2461177.935800452).abs() * 86400 >= 0.1 ||
        events[5].direction != MotionDirection.direct) {
      throw StateError('Event epoch or direction');
    }
    if ((events[6].time.jdTT - 2461192.99782962).abs() * 86400 >= 0.1 ||
        events[6].direction != MotionDirection.direct) {
      throw StateError('Event epoch or direction');
    }
    if ((events[7].time.jdTT - 2461262.1871686988).abs() * 86400 >= 0.1 ||
        events[7].direction != MotionDirection.direct) {
      throw StateError('Event epoch or direction');
    }
    if ((events[8].time.jdTT - 2461277.96206611).abs() * 86400 >= 0.1 ||
        events[8].direction != MotionDirection.direct) {
      throw StateError('Event epoch or direction');
    }
    if ((events[9].time.jdTT - 2461294.1818012185).abs() * 86400 >= 0.1 ||
        events[9].direction != MotionDirection.direct) {
      throw StateError('Event epoch or direction');
    }
    if ((events[10].time.jdTT - 2461313.989968296).abs() * 86400 >= 0.1 ||
        events[10].direction != MotionDirection.direct) {
      throw StateError('Event epoch or direction');
    }
    if ((events[11].time.jdTT - 2461380.857277956).abs() * 86400 >= 0.1 ||
        events[11].direction != MotionDirection.direct) {
      throw StateError('Event epoch or direction');
    }
    if ((events[12].time.jdTT - 2461400.266417276).abs() * 86400 >= 0.1 ||
        events[12].direction != MotionDirection.direct) {
      throw StateError('Event epoch or direction');
    }
  }
  {
    final events = searchIngresses(
      SkyBody.mercury,
      2460676.5,
      2461041.5,
      apparent: ApparentOptions(
        accuracy: Accuracy.accurate,
        frame: SkyFrame.trueOfDate,
      ),
    );
    if (events.length != 16) {
      throw StateError('Event count');
    }
    if ((events[0].time.jdTT - 2460683.9382681213).abs() * 86400 >= 0.1 ||
        events[0].direction != MotionDirection.direct) {
      throw StateError('Event epoch or direction');
    }
    if ((events[1].time.jdTT - 2460703.6207250915).abs() * 86400 >= 0.1 ||
        events[1].direction != MotionDirection.direct) {
      throw StateError('Event epoch or direction');
    }
    if ((events[2].time.jdTT - 2460721.005238127).abs() * 86400 >= 0.1 ||
        events[2].direction != MotionDirection.direct) {
      throw StateError('Event epoch or direction');
    }
    if ((events[3].time.jdTT - 2460737.878344815).abs() * 86400 >= 0.1 ||
        events[3].direction != MotionDirection.direct) {
      throw StateError('Event epoch or direction');
    }
    if ((events[4].time.jdTT - 2460764.5966234766).abs() * 86400 >= 0.1 ||
        events[4].direction != MotionDirection.retrograde) {
      throw StateError('Event epoch or direction');
    }
    if ((events[5].time.jdTT - 2460781.7682607286).abs() * 86400 >= 0.1 ||
        events[5].direction != MotionDirection.direct) {
      throw StateError('Event epoch or direction');
    }
    if ((events[6].time.jdTT - 2460806.011339184).abs() * 86400 >= 0.1 ||
        events[6].direction != MotionDirection.direct) {
      throw StateError('Event epoch or direction');
    }
    if ((events[7].time.jdTT - 2460821.542015303).abs() * 86400 >= 0.1 ||
        events[7].direction != MotionDirection.direct) {
      throw StateError('Event epoch or direction');
    }
    if ((events[8].time.jdTT - 2460835.4578816183).abs() * 86400 >= 0.1 ||
        events[8].direction != MotionDirection.direct) {
      throw StateError('Event epoch or direction');
    }
    if ((events[9].time.jdTT - 2460853.2987645753).abs() * 86400 >= 0.1 ||
        events[9].direction != MotionDirection.direct) {
      throw StateError('Event epoch or direction');
    }
    if ((events[10].time.jdTT - 2460921.058499571).abs() * 86400 >= 0.1 ||
        events[10].direction != MotionDirection.direct) {
      throw StateError('Event epoch or direction');
    }
    if ((events[11].time.jdTT - 2460936.9215421192).abs() * 86400 >= 0.1 ||
        events[11].direction != MotionDirection.direct) {
      throw StateError('Event epoch or direction');
    }
    if ((events[12].time.jdTT - 2460955.1957799457).abs() * 86400 >= 0.1 ||
        events[12].direction != MotionDirection.direct) {
      throw StateError('Event epoch or direction');
    }
    if ((events[13].time.jdTT - 2460977.9605617337).abs() * 86400 >= 0.1 ||
        events[13].direction != MotionDirection.direct) {
      throw StateError('Event epoch or direction');
    }
    if ((events[14].time.jdTT - 2460998.639900055).abs() * 86400 >= 0.1 ||
        events[14].direction != MotionDirection.retrograde) {
      throw StateError('Event epoch or direction');
    }
    if ((events[15].time.jdTT - 2461021.4450421445).abs() * 86400 >= 0.1 ||
        events[15].direction != MotionDirection.direct) {
      throw StateError('Event epoch or direction');
    }
  }
  {
    final events = searchStations(
      SkyBody.jupiter,
      2461041.5,
      2461406.5,
      apparent: ApparentOptions(
        accuracy: Accuracy.accurate,
        frame: SkyFrame.trueOfDate,
      ),
    );
    if (events.length != 2) {
      throw StateError('Event count');
    }
    if ((events[0].time.jdTT - 2461110.646531582).abs() * 86400 >= 0.1 ||
        events[0].direction != MotionDirection.direct) {
      throw StateError('Event epoch or direction');
    }
    if ((events[1].time.jdTT - 2461387.5400983095).abs() * 86400 >= 0.1 ||
        events[1].direction != MotionDirection.retrograde) {
      throw StateError('Event epoch or direction');
    }
  }
  {
    final events = searchLongitudeCrossings(
      SkyBody.mercury,
      330,
      2461041.5,
      2461406.5,
      apparent: ApparentOptions(
        accuracy: Accuracy.accurate,
        frame: SkyFrame.j2000,
      ),
    );
    if (events.length != 1) {
      throw StateError('Event count');
    }
    if ((events[0].time.jdTT - 2461078.659782801).abs() * 86400 >= 0.1 ||
        events[0].direction != MotionDirection.direct) {
      throw StateError('Event epoch or direction');
    }
  }
  {
    final m = moonIllumination(
      1721059.5,
      options: ApparentOptions(accuracy: Accuracy.fast, frame: SkyFrame.j2000),
    );
    if ((m.phaseCycle - 0.23423814239522756).abs() > 1e-12 ||
        m.waxing != true ||
        (m.illuminatedFraction! - 0.45198739588553394).abs() > 1e-12) {
      throw StateError('Moon phase');
    }
  }
  {
    final m = moonIllumination(
      1721059.5,
      options: ApparentOptions(
        accuracy: Accuracy.accurate,
        frame: SkyFrame.meanOfDate,
      ),
    );
    if ((m.phaseCycle - 0.23423688030557407).abs() > 1e-12 ||
        m.waxing != true ||
        (m.illuminatedFraction! - 0.45198347401218164).abs() > 1e-12) {
      throw StateError('Moon phase');
    }
  }
  {
    final m = moonIllumination(
      2415020.5,
      options: ApparentOptions(accuracy: Accuracy.mid, frame: SkyFrame.j2000),
    );
    if ((m.phaseCycle - 0.9785094692644966).abs() > 1e-12 ||
        m.waxing != false ||
        (m.illuminatedFraction! - 0.0046672605897474795).abs() > 1e-12) {
      throw StateError('Moon phase');
    }
  }
  {
    final m = moonIllumination(
      2415020.5,
      options: ApparentOptions(
        accuracy: Accuracy.fast,
        frame: SkyFrame.trueOfDate,
      ),
    );
    if ((m.phaseCycle - 0.9785092582576108).abs() > 1e-12 ||
        m.waxing != false ||
        (m.illuminatedFraction! - 0.004667405153529813).abs() > 1e-12) {
      throw StateError('Moon phase');
    }
  }
  {
    final m = moonIllumination(
      2451545,
      options: ApparentOptions(
        accuracy: Accuracy.accurate,
        frame: SkyFrame.j2000,
      ),
    );
    if ((m.phaseCycle - 0.8415185543874258).abs() > 1e-12 ||
        m.waxing != false ||
        (m.illuminatedFraction! - 0.23016541480603053).abs() > 1e-12) {
      throw StateError('Moon phase');
    }
  }
  {
    final m = moonIllumination(
      2451545,
      options: ApparentOptions(
        accuracy: Accuracy.mid,
        frame: SkyFrame.trueOfDate,
      ),
    );
    if ((m.phaseCycle - 0.8415184686326581).abs() > 1e-12 ||
        m.waxing != false ||
        (m.illuminatedFraction! - 0.23016564128585526).abs() > 1e-12) {
      throw StateError('Moon phase');
    }
  }
  {
    final m = moonIllumination(
      2461041.5,
      options: ApparentOptions(
        accuracy: Accuracy.fast,
        frame: SkyFrame.meanOfDate,
      ),
    );
    if ((m.phaseCycle - 0.4059333869173238).abs() > 1e-12 ||
        m.waxing != true ||
        (m.illuminatedFraction! - 0.9139055945289062).abs() > 1e-12) {
      throw StateError('Moon phase');
    }
  }
  {
    final m = moonIllumination(
      2461041.5,
      options: ApparentOptions(
        accuracy: Accuracy.accurate,
        frame: SkyFrame.trueOfDate,
      ),
    );
    if ((m.phaseCycle - 0.4059328280124112).abs() > 1e-12 ||
        m.waxing != true ||
        (m.illuminatedFraction! - 0.9139046800130016).abs() > 1e-12) {
      throw StateError('Moon phase');
    }
  }
  {
    final m = moonIllumination(
      2816787.5,
      options: ApparentOptions(
        accuracy: Accuracy.mid,
        frame: SkyFrame.meanOfDate,
      ),
    );
    if ((m.phaseCycle - 0.09336458118762102).abs() > 1e-12 ||
        m.waxing != true ||
        (m.illuminatedFraction! - 0.0856538919097134).abs() > 1e-12) {
      throw StateError('Moon phase');
    }
  }
  print('Passed 7 sky searches and 9 moon phase cross-runtime cases.');
}
