import 'dart:async';
import 'package:flutter/material.dart';


// Contains the logic to process the speed of the runner
class SpeedRegulator {
  double targetRunningSpeed;
  int steps = 0;

  int maxVol, currentVol;

  SpeedRegulator(double targetRunningSpeed) {
    this.targetRunningSpeed = targetRunningSpeed;
    calculateTargetstepsPerSecond();
  }


  bool abovePart = false;
  void countSteps(int zAcc) {
    if (zAcc > 6000) {
      if (!abovePart) {
        steps++;
      }
      abovePart = true;
    } else if (zAcc < 4500) {
      abovePart = false;
    }
  }

  Timer t;
  bool timerStarted = false;
  Duration d = Duration(seconds: 10);

  void startTimer() {
    steps = 0;
    t = Timer.periodic(d, (Timer timer) => handleTimeOut());
    print("started timer");
  }

  void stopTimer() {
    t.cancel();
    steps = 0;
    print("stopped timer");
  }

  void handleSpeedCheckTimer() async {
    if (!timerStarted) {
      startTimer();
    } else {
      stopTimer();
    }
    timerStarted = !timerStarted;
  }

  double stepsPerTime;
  double stepsPerSecond = 2; // 10 percent

  double targetStepsPerSecond;

  void calculateTargetstepsPerSecond() {
    // 1 step per second on lowest speed, 4 on highest.
    targetStepsPerSecond = 1 + (targetRunningSpeed * 3) / 100;
  }
  void handleTimeOut() {
    print("timer firing");
    stepsPerTime = steps / 10;
    double buffer = stepsPerSecond / 10;
    if (stepsPerTime > targetStepsPerSecond + buffer) {
    } else if (stepsPerTime < targetStepsPerSecond - buffer) {
    } else {
    }
    // reset amount of steps
    steps = 0;
  }

}

