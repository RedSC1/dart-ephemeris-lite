// GENERATED JS fixtures for Dart VM and compiled JS.
import 'package:ephemeris_lite/ephemeris_lite.dart';

void main() {
  {
    final o = CalendarOptions(mode: CalendarMode.chinaAstronomical);
    final a = solarToLunar(
      const CalendarDate(year: -6000, month: 1, day: 30),
      options: o,
    );
    if (a.year != -6001 ||
        a.historicalYear != -6001 ||
        a.month != 11 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion -6000/1/30');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != -6000 || s.month != 1 || s.day != 30) {
      throw StateError('Reverse conversion -6000/1/30');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.chinaAstronomical);
    final a = solarToLunar(
      const CalendarDate(year: -6000, month: 6, day: 24),
      options: o,
    );
    if (a.year != -6000 ||
        a.historicalYear != -6000 ||
        a.month != 4 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion -6000/6/24');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != -6000 || s.month != 6 || s.day != 24) {
      throw StateError('Reverse conversion -6000/6/24');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.chinaAstronomical);
    final a = solarToLunar(
      const CalendarDate(year: -6000, month: 11, day: 20),
      options: o,
    );
    if (a.year != -6000 ||
        a.historicalYear != -6000 ||
        a.month != 9 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion -6000/11/20');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != -6000 || s.month != 11 || s.day != 20) {
      throw StateError('Reverse conversion -6000/11/20');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.chinaAstronomical);
    final a = solarToLunar(
      const CalendarDate(year: -3000, month: 3, day: 12),
      options: o,
    );
    if (a.year != -3000 ||
        a.historicalYear != -3000 ||
        a.month != 1 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion -3000/3/12');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != -3000 || s.month != 3 || s.day != 12) {
      throw StateError('Reverse conversion -3000/3/12');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.chinaAstronomical);
    final a = solarToLunar(
      const CalendarDate(year: -3000, month: 8, day: 5),
      options: o,
    );
    if (a.year != -3000 ||
        a.historicalYear != -3000 ||
        a.month != 6 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion -3000/8/5');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != -3000 || s.month != 8 || s.day != 5) {
      throw StateError('Reverse conversion -3000/8/5');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.chinaAstronomical);
    final a = solarToLunar(
      const CalendarDate(year: -2999, month: 1, day: 1),
      options: o,
    );
    if (a.year != -3000 ||
        a.historicalYear != -3000 ||
        a.month != 11 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion -2999/1/1');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != -2999 || s.month != 1 || s.day != 1) {
      throw StateError('Reverse conversion -2999/1/1');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: -720, month: 4, day: 3),
      options: o,
    );
    if (a.year != -720 ||
        a.historicalYear != -720 ||
        a.month != 5 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion -720/4/3');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != -720 || s.month != 4 || s.day != 3) {
      throw StateError('Reverse conversion -720/4/3');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: -720, month: 8, day: 28),
      options: o,
    );
    if (a.year != -720 ||
        a.historicalYear != -720 ||
        a.month != 10 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion -720/8/28');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != -720 || s.month != 8 || s.day != 28) {
      throw StateError('Reverse conversion -720/8/28');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: -720, month: 11, day: 25),
      options: o,
    );
    if (a.year != -720 ||
        a.historicalYear != -720 ||
        a.month != 13 ||
        a.day != 1 ||
        a.isLeap != true ||
        a.monthDays != 29 ||
        a.monthName.index != 1) {
      throw StateError('Lunar conversion -720/11/25');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != -720 || s.month != 11 || s.day != 25) {
      throw StateError('Reverse conversion -720/11/25');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: -720, month: 12, day: 23),
      options: o,
    );
    if (a.year != -720 ||
        a.historicalYear != -720 ||
        a.month != 13 ||
        a.day != 29 ||
        a.isLeap != true ||
        a.monthDays != 29 ||
        a.monthName.index != 1) {
      throw StateError('Lunar conversion -720/12/23');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != -720 || s.month != 12 || s.day != 23) {
      throw StateError('Reverse conversion -720/12/23');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: -480, month: 12, day: 11),
      options: o,
    );
    if (a.year != -479 ||
        a.historicalYear != -479 ||
        a.month != 1 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion -480/12/11');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != -480 || s.month != 12 || s.day != 11) {
      throw StateError('Reverse conversion -480/12/11');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: -479, month: 5, day: 7),
      options: o,
    );
    if (a.year != -479 ||
        a.historicalYear != -479 ||
        a.month != 6 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion -479/5/7');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != -479 || s.month != 5 || s.day != 7) {
      throw StateError('Reverse conversion -479/5/7');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: -479, month: 10, day: 2),
      options: o,
    );
    if (a.year != -479 ||
        a.historicalYear != -479 ||
        a.month != 11 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion -479/10/2');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != -479 || s.month != 10 || s.day != 2) {
      throw StateError('Reverse conversion -479/10/2');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: -456, month: 2, day: 24),
      options: o,
    );
    if (a.year != -456 ||
        a.historicalYear != -456 ||
        a.month != 4 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion -456/2/24');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != -456 || s.month != 2 || s.day != 24) {
      throw StateError('Reverse conversion -456/2/24');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: -456, month: 7, day: 21),
      options: o,
    );
    if (a.year != -456 ||
        a.historicalYear != -456 ||
        a.month != 9 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion -456/7/21');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != -456 || s.month != 7 || s.day != 21) {
      throw StateError('Reverse conversion -456/7/21');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: -456, month: 11, day: 16),
      options: o,
    );
    if (a.year != -456 ||
        a.historicalYear != -456 ||
        a.month != 13 ||
        a.day != 1 ||
        a.isLeap != true ||
        a.monthDays != 29 ||
        a.monthName.index != 1) {
      throw StateError('Lunar conversion -456/11/16');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != -456 || s.month != 11 || s.day != 16) {
      throw StateError('Reverse conversion -456/11/16');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: -456, month: 12, day: 14),
      options: o,
    );
    if (a.year != -456 ||
        a.historicalYear != -456 ||
        a.month != 13 ||
        a.day != 29 ||
        a.isLeap != true ||
        a.monthDays != 29 ||
        a.monthName.index != 1) {
      throw StateError('Lunar conversion -456/12/14');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != -456 || s.month != 12 || s.day != 14) {
      throw StateError('Reverse conversion -456/12/14');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: -456, month: 12, day: 15),
      options: o,
    );
    if (a.year != -455 ||
        a.historicalYear != -455 ||
        a.month != 1 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion -456/12/15');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != -456 || s.month != 12 || s.day != 15) {
      throw StateError('Reverse conversion -456/12/15');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: -221, month: 4, day: 7),
      options: o,
    );
    if (a.year != -221 ||
        a.historicalYear != -221 ||
        a.month != 5 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion -221/4/7');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != -221 || s.month != 4 || s.day != 7) {
      throw StateError('Reverse conversion -221/4/7');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: -221, month: 9, day: 1),
      options: o,
    );
    if (a.year != -221 ||
        a.historicalYear != -221 ||
        a.month != 10 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion -221/9/1');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != -221 || s.month != 9 || s.day != 1) {
      throw StateError('Reverse conversion -221/9/1');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: -221, month: 12, day: 29),
      options: o,
    );
    if (a.year != -221 ||
        a.historicalYear != -220 ||
        a.month != 12 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion -221/12/29');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != -221 || s.month != 12 || s.day != 29) {
      throw StateError('Reverse conversion -221/12/29');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: -220, month: 5, day: 24),
      options: o,
    );
    if (a.year != -221 ||
        a.historicalYear != -220 ||
        a.month != 5 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion -220/5/24');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != -221 || s.month != 4 || s.day != 7) {
      throw StateError('Reverse conversion -220/5/24');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: -220, month: 10, day: 19),
      options: o,
    );
    if (a.year != -221 ||
        a.historicalYear != -220 ||
        a.month != 9 ||
        a.day != 1 ||
        a.isLeap != true ||
        a.monthDays != 30 ||
        a.monthName.index != 2) {
      throw StateError('Lunar conversion -220/10/19');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != -220 || s.month != 10 || s.day != 19) {
      throw StateError('Reverse conversion -220/10/19');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: -220, month: 11, day: 17),
      options: o,
    );
    if (a.year != -221 ||
        a.historicalYear != -220 ||
        a.month != 9 ||
        a.day != 30 ||
        a.isLeap != true ||
        a.monthDays != 30 ||
        a.monthName.index != 2) {
      throw StateError('Lunar conversion -220/11/17');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != -220 || s.month != 11 || s.day != 17) {
      throw StateError('Reverse conversion -220/11/17');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: -219, month: 2, day: 14),
      options: o,
    );
    if (a.year != -220 ||
        a.historicalYear != -219 ||
        a.month != 1 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion -219/2/14');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != -219 || s.month != 2 || s.day != 14) {
      throw StateError('Reverse conversion -219/2/14');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: -219, month: 7, day: 12),
      options: o,
    );
    if (a.year != -220 ||
        a.historicalYear != -219 ||
        a.month != 6 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion -219/7/12');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != -219 || s.month != 7 || s.day != 12) {
      throw StateError('Reverse conversion -219/7/12');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: -219, month: 12, day: 7),
      options: o,
    );
    if (a.year != -219 ||
        a.historicalYear != -218 ||
        a.month != 11 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion -219/12/7');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != -219 || s.month != 12 || s.day != 7) {
      throw StateError('Reverse conversion -219/12/7');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: -105, month: 4, day: 15),
      options: o,
    );
    if (a.year != -106 ||
        a.historicalYear != -105 ||
        a.month != 3 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion -105/4/15');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != -105 || s.month != 4 || s.day != 15) {
      throw StateError('Reverse conversion -105/4/15');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: -105, month: 9, day: 10),
      options: o,
    );
    if (a.year != -106 ||
        a.historicalYear != -105 ||
        a.month != 8 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion -105/9/10');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != -105 || s.month != 9 || s.day != 10) {
      throw StateError('Reverse conversion -105/9/10');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: -104, month: 1, day: 6),
      options: o,
    );
    if (a.year != -105 ||
        a.historicalYear != -104 ||
        a.month != 12 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion -104/1/6');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != -104 || s.month != 1 || s.day != 6) {
      throw StateError('Reverse conversion -104/1/6');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: -104, month: 6, day: 2),
      options: o,
    );
    if (a.year != -105 ||
        a.historicalYear != -104 ||
        a.month != 5 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion -104/6/2');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != -104 || s.month != 6 || s.day != 2) {
      throw StateError('Reverse conversion -104/6/2');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: -104, month: 10, day: 27),
      options: o,
    );
    if (a.year != -105 ||
        a.historicalYear != -104 ||
        a.month != 9 ||
        a.day != 1 ||
        a.isLeap != true ||
        a.monthDays != 30 ||
        a.monthName.index != 2) {
      throw StateError('Lunar conversion -104/10/27');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != -104 || s.month != 10 || s.day != 27) {
      throw StateError('Reverse conversion -104/10/27');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: -104, month: 11, day: 25),
      options: o,
    );
    if (a.year != -105 ||
        a.historicalYear != -104 ||
        a.month != 9 ||
        a.day != 30 ||
        a.isLeap != true ||
        a.monthDays != 30 ||
        a.monthName.index != 2) {
      throw StateError('Lunar conversion -104/11/25');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != -104 || s.month != 11 || s.day != 25) {
      throw StateError('Reverse conversion -104/11/25');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: -103, month: 3, day: 23),
      options: o,
    );
    if (a.year != -103 ||
        a.historicalYear != -103 ||
        a.month != 2 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion -103/3/23');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != -103 || s.month != 3 || s.day != 23) {
      throw StateError('Reverse conversion -103/3/23');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: -103, month: 8, day: 18),
      options: o,
    );
    if (a.year != -103 ||
        a.historicalYear != -103 ||
        a.month != 7 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion -103/8/18');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != -103 || s.month != 8 || s.day != 18) {
      throw StateError('Reverse conversion -103/8/18');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: -1, month: 11, day: 27),
      options: o,
    );
    if (a.year != -1 ||
        a.historicalYear != -1 ||
        a.month != 11 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion -1/11/27');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != -1 || s.month != 11 || s.day != 27) {
      throw StateError('Reverse conversion -1/11/27');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 0, month: 4, day: 23),
      options: o,
    );
    if (a.year != 0 ||
        a.historicalYear != 0 ||
        a.month != 3 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 0/4/23');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 0 || s.month != 4 || s.day != 23) {
      throw StateError('Reverse conversion 0/4/23');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 0, month: 9, day: 18),
      options: o,
    );
    if (a.year != 0 ||
        a.historicalYear != 0 ||
        a.month != 8 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 0/9/18');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 0 || s.month != 9 || s.day != 18) {
      throw StateError('Reverse conversion 0/9/18');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 9, month: 1, day: 15),
      options: o,
    );
    if (a.year != 9 ||
        a.historicalYear != 9 ||
        a.month != 1 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 9/1/15');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 9 || s.month != 1 || s.day != 15) {
      throw StateError('Reverse conversion 9/1/15');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 9, month: 6, day: 12),
      options: o,
    );
    if (a.year != 9 ||
        a.historicalYear != 9 ||
        a.month != 6 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 9/6/12');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 9 || s.month != 6 || s.day != 12) {
      throw StateError('Reverse conversion 9/6/12');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 9, month: 11, day: 7),
      options: o,
    );
    if (a.year != 9 ||
        a.historicalYear != 9 ||
        a.month != 11 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 9/11/7');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 9 || s.month != 11 || s.day != 7) {
      throw StateError('Reverse conversion 9/11/7');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 10, month: 3, day: 5),
      options: o,
    );
    if (a.year != 10 ||
        a.historicalYear != 10 ||
        a.month != 3 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 10/3/5');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 10 || s.month != 3 || s.day != 5) {
      throw StateError('Reverse conversion 10/3/5');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 10, month: 7, day: 30),
      options: o,
    );
    if (a.year != 10 ||
        a.historicalYear != 10 ||
        a.month != 8 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 10/7/30');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 10 || s.month != 7 || s.day != 30) {
      throw StateError('Reverse conversion 10/7/30');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 22, month: 12, day: 13),
      options: o,
    );
    if (a.year != 22 ||
        a.historicalYear != 22 ||
        a.month != 12 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 22/12/13');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 22 || s.month != 12 || s.day != 13) {
      throw StateError('Reverse conversion 22/12/13');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 23, month: 5, day: 9),
      options: o,
    );
    if (a.year != 23 ||
        a.historicalYear != 23 ||
        a.month != 5 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 23/5/9');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 23 || s.month != 5 || s.day != 9) {
      throw StateError('Reverse conversion 23/5/9');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 23, month: 10, day: 4),
      options: o,
    );
    if (a.year != 23 ||
        a.historicalYear != 23 ||
        a.month != 10 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 23/10/4');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 23 || s.month != 10 || s.day != 4) {
      throw StateError('Reverse conversion 23/10/4');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 23, month: 12, day: 2),
      options: o,
    );
    if (a.year != 23 ||
        a.historicalYear != 23 ||
        a.month != 12 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 3) {
      throw StateError('Lunar conversion 23/12/2');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 23 || s.month != 12 || s.day != 2) {
      throw StateError('Reverse conversion 23/12/2');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 23, month: 12, day: 30),
      options: o,
    );
    if (a.year != 23 ||
        a.historicalYear != 23 ||
        a.month != 12 ||
        a.day != 29 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 3) {
      throw StateError('Lunar conversion 23/12/30');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 23 || s.month != 12 || s.day != 30) {
      throw StateError('Reverse conversion 23/12/30');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 237, month: 2, day: 13),
      options: o,
    );
    if (a.year != 237 ||
        a.historicalYear != 237 ||
        a.month != 1 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 237/2/13');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 237 || s.month != 2 || s.day != 13) {
      throw StateError('Reverse conversion 237/2/13');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 237, month: 7, day: 10),
      options: o,
    );
    if (a.year != 237 ||
        a.historicalYear != 237 ||
        a.month != 7 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 237/7/10');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 237 || s.month != 7 || s.day != 10) {
      throw StateError('Reverse conversion 237/7/10');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 237, month: 12, day: 5),
      options: o,
    );
    if (a.year != 237 ||
        a.historicalYear != 237 ||
        a.month != 12 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 237/12/5');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 237 || s.month != 12 || s.day != 5) {
      throw StateError('Reverse conversion 237/12/5');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 238, month: 4, day: 2),
      options: o,
    );
    if (a.year != 238 ||
        a.historicalYear != 238 ||
        a.month != 4 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 238/4/2');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 238 || s.month != 4 || s.day != 2) {
      throw StateError('Reverse conversion 238/4/2');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 238, month: 8, day: 28),
      options: o,
    );
    if (a.year != 238 ||
        a.historicalYear != 238 ||
        a.month != 9 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 238/8/28');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 238 || s.month != 8 || s.day != 28) {
      throw StateError('Reverse conversion 238/8/28');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 239, month: 1, day: 22),
      options: o,
    );
    if (a.year != 239 ||
        a.historicalYear != 239 ||
        a.month != 1 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 239/1/22');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 239 || s.month != 1 || s.day != 22) {
      throw StateError('Reverse conversion 239/1/22');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 239, month: 6, day: 19),
      options: o,
    );
    if (a.year != 239 ||
        a.historicalYear != 239 ||
        a.month != 6 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 239/6/19');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 239 || s.month != 6 || s.day != 19) {
      throw StateError('Reverse conversion 239/6/19');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 239, month: 11, day: 13),
      options: o,
    );
    if (a.year != 239 ||
        a.historicalYear != 239 ||
        a.month != 11 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 239/11/13');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 239 || s.month != 11 || s.day != 13) {
      throw StateError('Reverse conversion 239/11/13');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 239, month: 12, day: 13),
      options: o,
    );
    if (a.year != 239 ||
        a.historicalYear != 239 ||
        a.month != 12 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 3) {
      throw StateError('Lunar conversion 239/12/13');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 239 || s.month != 12 || s.day != 13) {
      throw StateError('Reverse conversion 239/12/13');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 240, month: 1, day: 11),
      options: o,
    );
    if (a.year != 239 ||
        a.historicalYear != 239 ||
        a.month != 12 ||
        a.day != 30 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 3) {
      throw StateError('Lunar conversion 240/1/11');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 240 || s.month != 1 || s.day != 11) {
      throw StateError('Reverse conversion 240/1/11');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 689, month: 2, day: 25),
      options: o,
    );
    if (a.year != 689 ||
        a.historicalYear != 689 ||
        a.month != 2 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 689/2/25');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 689 || s.month != 2 || s.day != 25) {
      throw StateError('Reverse conversion 689/2/25');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 689, month: 7, day: 22),
      options: o,
    );
    if (a.year != 689 ||
        a.historicalYear != 689 ||
        a.month != 7 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 689/7/22');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 689 || s.month != 7 || s.day != 22) {
      throw StateError('Reverse conversion 689/7/22');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 689, month: 12, day: 18),
      options: o,
    );
    if (a.year != 690 ||
        a.historicalYear != 690 ||
        a.month != 1 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 689/12/18');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 689 || s.month != 12 || s.day != 18) {
      throw StateError('Reverse conversion 689/12/18');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 690, month: 2, day: 15),
      options: o,
    );
    if (a.year != 690 ||
        a.historicalYear != 690 ||
        a.month != 1 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 4) {
      throw StateError('Lunar conversion 690/2/15');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 690 || s.month != 2 || s.day != 15) {
      throw StateError('Reverse conversion 690/2/15');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 690, month: 3, day: 15),
      options: o,
    );
    if (a.year != 690 ||
        a.historicalYear != 690 ||
        a.month != 1 ||
        a.day != 29 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 4) {
      throw StateError('Lunar conversion 690/3/15');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 690 || s.month != 3 || s.day != 15) {
      throw StateError('Reverse conversion 690/3/15');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 690, month: 5, day: 14),
      options: o,
    );
    if (a.year != 690 ||
        a.historicalYear != 690 ||
        a.month != 4 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 690/5/14');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 690 || s.month != 5 || s.day != 14) {
      throw StateError('Reverse conversion 690/5/14');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 690, month: 10, day: 8),
      options: o,
    );
    if (a.year != 690 ||
        a.historicalYear != 690 ||
        a.month != 9 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 690/10/8');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 690 || s.month != 10 || s.day != 8) {
      throw StateError('Reverse conversion 690/10/8');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 700, month: 1, day: 26),
      options: o,
    );
    if (a.year != 700 ||
        a.historicalYear != 700 ||
        a.month != 1 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 4) {
      throw StateError('Lunar conversion 700/1/26');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 700 || s.month != 1 || s.day != 26) {
      throw StateError('Reverse conversion 700/1/26');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 700, month: 2, day: 24),
      options: o,
    );
    if (a.year != 700 ||
        a.historicalYear != 700 ||
        a.month != 1 ||
        a.day != 30 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 4) {
      throw StateError('Lunar conversion 700/2/24');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 700 || s.month != 2 || s.day != 24) {
      throw StateError('Reverse conversion 700/2/24');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 700, month: 6, day: 21),
      options: o,
    );
    if (a.year != 700 ||
        a.historicalYear != 700 ||
        a.month != 6 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 700/6/21');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 700 || s.month != 6 || s.day != 21) {
      throw StateError('Reverse conversion 700/6/21');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 700, month: 11, day: 15),
      options: o,
    );
    if (a.year != 700 ||
        a.historicalYear != 700 ||
        a.month != 10 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 700/11/15');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 700 || s.month != 11 || s.day != 15) {
      throw StateError('Reverse conversion 700/11/15');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 701, month: 1, day: 14),
      options: o,
    );
    if (a.year != 700 ||
        a.historicalYear != 700 ||
        a.month != 12 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 5) {
      throw StateError('Lunar conversion 701/1/14');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 701 || s.month != 1 || s.day != 14) {
      throw StateError('Reverse conversion 701/1/14');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 701, month: 2, day: 12),
      options: o,
    );
    if (a.year != 700 ||
        a.historicalYear != 700 ||
        a.month != 12 ||
        a.day != 30 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 5) {
      throw StateError('Lunar conversion 701/2/12');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 701 || s.month != 2 || s.day != 12) {
      throw StateError('Reverse conversion 701/2/12');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 701, month: 3, day: 14),
      options: o,
    );
    if (a.year != 701 ||
        a.historicalYear != 701 ||
        a.month != 2 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 701/3/14');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 701 || s.month != 3 || s.day != 14) {
      throw StateError('Reverse conversion 701/3/14');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 701, month: 8, day: 9),
      options: o,
    );
    if (a.year != 701 ||
        a.historicalYear != 701 ||
        a.month != 7 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 701/8/9');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 701 || s.month != 8 || s.day != 9) {
      throw StateError('Reverse conversion 701/8/9');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 760, month: 12, day: 12),
      options: o,
    );
    if (a.year != 760 ||
        a.historicalYear != 760 ||
        a.month != 11 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 760/12/12');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 760 || s.month != 12 || s.day != 12) {
      throw StateError('Reverse conversion 760/12/12');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 761, month: 5, day: 9),
      options: o,
    );
    if (a.year != 761 ||
        a.historicalYear != 761 ||
        a.month != 4 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 761/5/9');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 761 || s.month != 5 || s.day != 9) {
      throw StateError('Reverse conversion 761/5/9');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 761, month: 10, day: 3),
      options: o,
    );
    if (a.year != 761 ||
        a.historicalYear != 761 ||
        a.month != 9 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 761/10/3');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 761 || s.month != 10 || s.day != 3) {
      throw StateError('Reverse conversion 761/10/3');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 762, month: 1, day: 30),
      options: o,
    );
    if (a.year != 762 ||
        a.historicalYear != 762 ||
        a.month != 3 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 762/1/30');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 762 || s.month != 1 || s.day != 30) {
      throw StateError('Reverse conversion 762/1/30');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 762, month: 5, day: 28),
      options: o,
    );
    if (a.year != 762 ||
        a.historicalYear != 762 ||
        a.month != 5 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 5) {
      throw StateError('Lunar conversion 762/5/28');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 762 || s.month != 5 || s.day != 28) {
      throw StateError('Reverse conversion 762/5/28');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 762, month: 6, day: 26),
      options: o,
    );
    if (a.year != 762 ||
        a.historicalYear != 762 ||
        a.month != 5 ||
        a.day != 30 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 5) {
      throw StateError('Lunar conversion 762/6/26');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 762 || s.month != 6 || s.day != 26) {
      throw StateError('Reverse conversion 762/6/26');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 762, month: 6, day: 27),
      options: o,
    );
    if (a.year != 762 ||
        a.historicalYear != 762 ||
        a.month != 6 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 762/6/27');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 762 || s.month != 6 || s.day != 27) {
      throw StateError('Reverse conversion 762/6/27');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 762, month: 11, day: 21),
      options: o,
    );
    if (a.year != 762 ||
        a.historicalYear != 762 ||
        a.month != 11 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 762/11/21');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 762 || s.month != 11 || s.day != 21) {
      throw StateError('Reverse conversion 762/11/21');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 1582, month: 3, day: 24),
      options: o,
    );
    if (a.year != 1582 ||
        a.historicalYear != 1582 ||
        a.month != 3 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 1582/3/24');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 1582 || s.month != 3 || s.day != 24) {
      throw StateError('Reverse conversion 1582/3/24');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 1582, month: 8, day: 18),
      options: o,
    );
    if (a.year != 1582 ||
        a.historicalYear != 1582 ||
        a.month != 8 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 1582/8/18');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 1582 || s.month != 8 || s.day != 18) {
      throw StateError('Reverse conversion 1582/8/18');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 1900, month: 1, day: 1),
      options: o,
    );
    if (a.year != 1899 ||
        a.historicalYear != 1899 ||
        a.month != 12 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 1900/1/1');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 1900 || s.month != 1 || s.day != 1) {
      throw StateError('Reverse conversion 1900/1/1');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 1900, month: 5, day: 28),
      options: o,
    );
    if (a.year != 1900 ||
        a.historicalYear != 1900 ||
        a.month != 5 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 1900/5/28');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 1900 || s.month != 5 || s.day != 28) {
      throw StateError('Reverse conversion 1900/5/28');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 1900, month: 10, day: 23),
      options: o,
    );
    if (a.year != 1900 ||
        a.historicalYear != 1900 ||
        a.month != 9 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 1900/10/23');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 1900 || s.month != 10 || s.day != 23) {
      throw StateError('Reverse conversion 1900/10/23');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 2025, month: 2, day: 28),
      options: o,
    );
    if (a.year != 2025 ||
        a.historicalYear != 2025 ||
        a.month != 2 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 2025/2/28');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 2025 || s.month != 2 || s.day != 28) {
      throw StateError('Reverse conversion 2025/2/28');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 2025, month: 7, day: 25),
      options: o,
    );
    if (a.year != 2025 ||
        a.historicalYear != 2025 ||
        a.month != 6 ||
        a.day != 1 ||
        a.isLeap != true ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 2025/7/25');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 2025 || s.month != 7 || s.day != 25) {
      throw StateError('Reverse conversion 2025/7/25');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 2025, month: 12, day: 20),
      options: o,
    );
    if (a.year != 2025 ||
        a.historicalYear != 2025 ||
        a.month != 11 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 2025/12/20');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 2025 || s.month != 12 || s.day != 20) {
      throw StateError('Reverse conversion 2025/12/20');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 2026, month: 4, day: 17),
      options: o,
    );
    if (a.year != 2026 ||
        a.historicalYear != 2026 ||
        a.month != 3 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 2026/4/17');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 2026 || s.month != 4 || s.day != 17) {
      throw StateError('Reverse conversion 2026/4/17');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 2026, month: 9, day: 11),
      options: o,
    );
    if (a.year != 2026 ||
        a.historicalYear != 2026 ||
        a.month != 8 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 2026/9/11');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 2026 || s.month != 9 || s.day != 11) {
      throw StateError('Reverse conversion 2026/9/11');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 2033, month: 1, day: 1),
      options: o,
    );
    if (a.year != 2032 ||
        a.historicalYear != 2032 ||
        a.month != 12 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 2033/1/1');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 2033 || s.month != 1 || s.day != 1) {
      throw StateError('Reverse conversion 2033/1/1');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 2033, month: 5, day: 28),
      options: o,
    );
    if (a.year != 2033 ||
        a.historicalYear != 2033 ||
        a.month != 5 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 2033/5/28');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 2033 || s.month != 5 || s.day != 28) {
      throw StateError('Reverse conversion 2033/5/28');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 2033, month: 10, day: 23),
      options: o,
    );
    if (a.year != 2033 ||
        a.historicalYear != 2033 ||
        a.month != 10 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 2033/10/23');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 2033 || s.month != 10 || s.day != 23) {
      throw StateError('Reverse conversion 2033/10/23');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 2034, month: 2, day: 19),
      options: o,
    );
    if (a.year != 2034 ||
        a.historicalYear != 2034 ||
        a.month != 1 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 2034/2/19');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 2034 || s.month != 2 || s.day != 19) {
      throw StateError('Reverse conversion 2034/2/19');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 2034, month: 7, day: 16),
      options: o,
    );
    if (a.year != 2034 ||
        a.historicalYear != 2034 ||
        a.month != 6 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 2034/7/16');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 2034 || s.month != 7 || s.day != 16) {
      throw StateError('Reverse conversion 2034/7/16');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 2034, month: 12, day: 11),
      options: o,
    );
    if (a.year != 2034 ||
        a.historicalYear != 2034 ||
        a.month != 11 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 2034/12/11');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 2034 || s.month != 12 || s.day != 11) {
      throw StateError('Reverse conversion 2034/12/11');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 3000, month: 3, day: 28),
      options: o,
    );
    if (a.year != 3000 ||
        a.historicalYear != 3000 ||
        a.month != 3 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 3000/3/28');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 3000 || s.month != 3 || s.day != 28) {
      throw StateError('Reverse conversion 3000/3/28');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.historical);
    final a = solarToLunar(
      const CalendarDate(year: 3000, month: 8, day: 22),
      options: o,
    );
    if (a.year != 3000 ||
        a.historicalYear != 3000 ||
        a.month != 7 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 3000/8/22');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 3000 || s.month != 8 || s.day != 22) {
      throw StateError('Reverse conversion 3000/8/22');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.chinaAstronomical);
    final a = solarToLunar(
      const CalendarDate(year: 9998, month: 12, day: 11),
      options: o,
    );
    if (a.year != 9998 ||
        a.historicalYear != 9998 ||
        a.month != 11 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 9998/12/11');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 9998 || s.month != 12 || s.day != 11) {
      throw StateError('Reverse conversion 9998/12/11');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.chinaAstronomical);
    final a = solarToLunar(
      const CalendarDate(year: 9999, month: 5, day: 7),
      options: o,
    );
    if (a.year != 9999 ||
        a.historicalYear != 9999 ||
        a.month != 4 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 30 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 9999/5/7');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 9999 || s.month != 5 || s.day != 7) {
      throw StateError('Reverse conversion 9999/5/7');
    }
  }
  {
    final o = CalendarOptions(mode: CalendarMode.chinaAstronomical);
    final a = solarToLunar(
      const CalendarDate(year: 9999, month: 10, day: 2),
      options: o,
    );
    if (a.year != 9999 ||
        a.historicalYear != 9999 ||
        a.month != 9 ||
        a.day != 1 ||
        a.isLeap != false ||
        a.monthDays != 29 ||
        a.monthName.index != 0) {
      throw StateError('Lunar conversion 9999/10/2');
    }
    final s = lunarToSolar(a, options: o);
    if (s.year != 9999 || s.month != 10 || s.day != 2) {
      throw StateError('Reverse conversion 9999/10/2');
    }
  }
  print('Passed 102 cross-runtime lunar cases.');
}
