import 'package:flutter/material.dart';
import 'package:traffic_lights/traffic_light.dart';

import 'dart:math';

import 'package:traffic_lights/traffic_light_objects.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Traffic Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {

  MyHomePage({super.key, required this.title});

  final String title;

  // feel free to play with the timing
  final TrafficLightSchedule trafficLightSchedule = TrafficLightSchedule(
    lamps: [
      TrafficLamp(
          onColor: Colors.red,
          schedule: [
            TrafficLampScheduleEntry(
                start: 0,
                end: 4500
            )
          ]
      ),
      TrafficLamp(
          onColor: Colors.yellow,
          schedule: [
            TrafficLampScheduleEntry(
                start: 3000,
                end: 4500
            ),
            TrafficLampScheduleEntry(
                start: 7500,
                end: 9000
            )
          ]
      ),
      TrafficLamp(
          onColor: Colors.green,
          schedule: [
            TrafficLampScheduleEntry(
                start: 4500,
                end: 7500
            )
          ]
      )
    ]
  );


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  bool chaosMode = false;

  late AnimationController syncedController;
  AnimationController? animationController;
  late Duration animationDuration;




  @override
  void initState() {
    super.initState();
    syncedController = AnimationController(duration: widget.trafficLightSchedule.lampScheduleDuration, vsync: this);

    animationController = null;
    chaosMode = true;
  }

  // 5 * 200 = 1000
  // but feel free to increase it further then that it'll work just the same
  int colCount = 5;
  int rowCount = 200;

  DateTime startTime = DateTime.now();

  void switchMode() {
    setState(() {
      startTime = DateTime.now();
      chaosMode = !chaosMode;
      if (chaosMode) {
        syncedController.reset();
        animationController = null;
      }
      else {
        animationController = syncedController;
        Future.delayed(Duration.zero, () {
          syncedController.repeat();
        });
      }
    });
  }


  Widget buildModeButton() {
    return SizedBox(
      width: 100,
      child: FloatingActionButton(
        onPressed: switchMode,
        child: Text(chaosMode ? "Synchronize" : "Chaos"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: rowCount,
        shrinkWrap: true,
        itemBuilder: (ctx, rowIndex) {
          return Padding(
            padding: EdgeInsets.all(5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (int colIndex = 0; colIndex < colCount; colIndex++) ...[
                  TrafficLight(
                    // key forces rebuild on changing chaosMode
                    key: Key("TrafficLight-${rowIndex * colCount + colIndex}-$chaosMode"),
                    trafficLightSchedule: widget.trafficLightSchedule,
                    animationController: animationController,
                    lightHeight: 100,
                    lightWidth: 50,
                    lampWidth: 20,
                    lampHeight: 20,
                    startTime: startTime,
                  )
                ]
              ],
            ),
          );
        },
      ),
      floatingActionButton: buildModeButton(), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
