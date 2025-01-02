import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:traffic_lights/traffic_light_objects.dart';

class TrafficLight extends StatefulWidget {

  TrafficLightSchedule trafficLightSchedule;
  AnimationController? animationController;
  DateTime startTime;

  double lightWidth;
  double lightHeight;
  double lampWidth;
  double lampHeight;

  TrafficLight({
    super.key,
    required this.trafficLightSchedule,
    this.animationController,
    required this.lightHeight,
    required this.lightWidth,
    required this.lampHeight,
    required this.lampWidth,
    required this.startTime
  });

  @override
  State<TrafficLight> createState() => _TrafficLightState();
}


class _TrafficLightState extends State<TrafficLight> with SingleTickerProviderStateMixin {

  AnimationController? animationController;
  late Duration animationDelay;
  late Duration totalDuration;

  @override
  void initState() {
    super.initState();

    if (widget.animationController == null) {
      runChaosMode();
    }
    else {
      runSyncedMode();
    }
  }

  void runSyncedMode() {
    animationController?.dispose();
    animationController = widget.animationController!;
    animationDelay = Duration.zero;
    totalDuration = widget.trafficLightSchedule.lampScheduleDuration;
  }

  void resetAnimationDelay() {
    animationDelay = Duration(milliseconds: Random().nextInt(5000));
  }


  void chaosControllerListener(AnimationStatus status) {
    if (animationController!.isCompleted) {
      animationController!.removeStatusListener(chaosControllerListener);
      totalDuration = widget.trafficLightSchedule.lampScheduleDuration;
      animationDelay = Duration.zero;
      animationController!.duration = totalDuration;
      animationController!.repeat();
    }
  }

  void startRepeatOnComplete(AnimationStatus status) {
    if (animationController!.isCompleted) {
      animationController!.removeStatusListener(startRepeatOnComplete);
      animationController!.repeat();
    }
  }

  void runChaosMode() {
    resetAnimationDelay();
    totalDuration = animationDelay + widget.trafficLightSchedule.lampScheduleDuration;

    Duration initDelay = DateTime.now().difference(widget.startTime);
    double relativeAnimationValue = initDelay.inMilliseconds / totalDuration.inMilliseconds;

    if (relativeAnimationValue > 1) {
      double startPoint = ((initDelay.inMilliseconds - animationDelay.inMilliseconds)
          / widget.trafficLightSchedule.lampScheduleDuration.inMilliseconds) % 1;
      animationDelay = Duration.zero;
      totalDuration = widget.trafficLightSchedule.lampScheduleDuration;
      animationController = AnimationController(
          duration: totalDuration,
          vsync: this
      );
      animationController!.addStatusListener(startRepeatOnComplete);
      animationController!.forward(from: startPoint);
    }
    else {
      animationController = AnimationController(
          duration: totalDuration,
          vsync: this
      );
      animationController!.addStatusListener(chaosControllerListener);
      animationController!.forward(from: relativeAnimationValue);
    }
  }

  @override
  void dispose() {
    if (animationController != widget.animationController) {
      animationController?.dispose();
    }
    super.dispose();
  }

  double getMillisecondTick(double animationValue) {
    // calculate current millisecond by getting the percentage of total duration using animationValue which represents controller percentage
    // then subtract delay
    double currentTick = totalDuration.inMilliseconds * animationValue - animationDelay.inMilliseconds;
    if (currentTick < 0) {
      // implies animation is currently still being delayed due to chaos mode
      return 0;
    }
    if (currentTick > widget.trafficLightSchedule.lampScheduleDuration.inMilliseconds) {
      // this cant really happen ever but might as well add it just in case
      return widget.trafficLightSchedule.lampScheduleDuration.inMilliseconds.toDouble();
    }
    return currentTick;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: widget.lightWidth,
        height: widget.lightHeight,
        color: Colors.grey,
        child: AnimatedBuilder(
            animation: animationController!,
            builder: (context, child) {
              var tick = getMillisecondTick(animationController!.value);
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (var lamp in widget.trafficLightSchedule.lamps) ...[
                    Container(
                      color: lamp.isLampOn(tick)
                          ? lamp.onColor
                          : lamp.offColor,
                      width: widget.lampWidth,
                      height: widget.lampHeight,
                    ),
                  ],
                  // I recommend showing this when explaining how the chaos delay works
                  // Text((tick.floor()).toString()),
                  // Text("${animationController?.duration?.inMilliseconds}")
                ],
              );
            }
        )
    );
  }
}