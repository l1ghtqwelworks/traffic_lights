
import 'dart:math';
import 'dart:ui';

class TrafficLightSchedule {

  late List<TrafficLamp> lamps;
  late Duration lampScheduleDuration;

  int getMaxEntryEnd(List<TrafficLamp> lamps) {
    int maxEnd = 0;
    for (var lamp in lamps) {
      for (var entry in lamp.schedule) {
        maxEnd = max(maxEnd, entry.end);
      }
    }
    return maxEnd;
  }


  TrafficLightSchedule({
    required this.lamps,
  }) {
    lampScheduleDuration = Duration(milliseconds: getMaxEntryEnd(lamps));
  }
}

class TrafficLampScheduleEntry {
  int start;
  int end;
  TrafficLampScheduleEntry({
    required this.start,
    required this.end
  });
}

class TrafficLamp {
  Color onColor;
  late Color offColor;
  List<TrafficLampScheduleEntry> schedule;

  TrafficLamp({
    required this.onColor,
    required this.schedule
  }) {
    offColor = onColor.withAlpha(80);
  }


  bool isLampOn(num time) {
    for (var entry in schedule) {
      if (time >= entry.start && time <= entry.end) {
        return true;
      }
    }
    return false;
  }
}
