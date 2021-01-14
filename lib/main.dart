import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:esense_flutter/esense.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MaterialApp(
    title: "Sports Coordinator",
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  LandingPage createState() => LandingPage();
}

class LandingPage extends State<MyApp> {
  String _deviceName = 'Unknown';
  String _deviceStatus = '';
  bool sampling = false;
  String _event = '';
  StreamSubscription subscription;

  String eSenseNameRight = 'eSense-0508';

  @override
  void initState() {
    super.initState();
    _connectToESense();
  }

  Future<void> _connectToESense() async {
    bool con = false;

    // if you want to get the connection events when connecting, set up the listener BEFORE connecting...
    ESenseManager.connectionEvents.listen((event) {
      print('CONNECTION event: $event');

      // when we're connected to the eSense device, we can start listening to events from it
      if (event.type == ConnectionType.connected) _listenToESenseEvents();

      setState(() {
        switch (event.type) {
          case ConnectionType.connected:
            _deviceStatus = 'connected';
            break;
          case ConnectionType.unknown:
            _deviceStatus = 'unknown';
            break;
          case ConnectionType.disconnected:
            _deviceStatus = 'disconnected';
            break;
          case ConnectionType.device_found:
            _deviceStatus = 'device_found';
            break;
          case ConnectionType.device_not_found:
            _deviceStatus = 'device_not_found';
            break;
        }
      });
    });

    con = await ESenseManager.connect(eSenseNameRight);

    setState(() {
      _deviceStatus = con ? 'connecting' : 'connection failed';
    });
  }

  void _listenToESenseEvents() {
    ESenseManager.eSenseEvents.listen((event) {
      print('ESENSE event: $event');

      setState(() {
        switch (event.runtimeType) {
          case DeviceNameRead:
            _deviceName = (event as DeviceNameRead).deviceName;
            break;
        }
      });
    });

    _getESenseProperties();
  }

  void _getESenseProperties() async {
    // get the battery level every 10 secs
    Timer.periodic(Duration(seconds: 10),
        (timer) async => await ESenseManager.getBatteryVoltage());

    // wait 2, 3, 4, 5, ... secs before getting the name, offset, etc.
    // it seems like the eSense BTLE interface does NOT like to get called
    // several times in a row -- hence, delays are added in the following calls
    Timer(
        Duration(seconds: 2), () async => await ESenseManager.getDeviceName());
    Timer(Duration(seconds: 3),
        () async => await ESenseManager.getAccelerometerOffset());
    Timer(
        Duration(seconds: 4),
        () async =>
            await ESenseManager.getAdvertisementAndConnectionInterval());
    Timer(Duration(seconds: 5),
        () async => await ESenseManager.getSensorConfig());
  }

  void _startListenToSensorEvents() async {
    print("entered startListeningToSensorEvents() fct()");
    // subscribe to sensor event from the eSense device
    if (!sampling) {
      subscription = ESenseManager.sensorEvents.listen((event) {
        List<int> acc = event.accel;
        List<int> gyro = event.gyro;

        print('SENSOR event: $event');
        setState(() {
          print(acc);
          print(gyro);
          _event = event.toString();
        });
      });
      sampling = true;
    }
  }

  void _pauseListenToSensorEvents() {
    //speedRegulator.steps = 0;
    subscription.cancel();
    setState(() {
      sampling = false;
    });
  }

  void dispose() {
    _pauseListenToSensorEvents();
    ESenseManager.disconnect();
    super.dispose();
  }

  void ListeningToSensorEventsButtonEffect() {
    print("entered ListeningToSensorEventsButtonEffect() fct");
    if (ESenseManager.connected) {
      print("sampling: \t$sampling");
      if (!sampling) {
        _startListenToSensorEvents();
      } else {
        _pauseListenToSensorEvents();
      }
    }
  }

  void connectToBLEButtonEffect(BuildContext context) {
    // only try connection if not already connected
    if (!ESenseManager.connected) {
      _connectToESense();
    } else {
      print("already connected to eSense via bluetooth");
    }
  }

  Widget build(BuildContext context) {
    const String title = "Sports Coordinator";
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      home: Scaffold(
        appBar: ESenseManager.connected
            ? AppBar(
                title: const Text(title),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.headset,
                      color: Colors.white,
                    ),
                  )
                ],
                backgroundColor: Colors.cyan[700])
            : AppBar(
                title: const Text(title),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.headset_off,
                      color: Colors.white,
                    ),
                  )
                ],
                backgroundColor: Colors.cyan[700]),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Wählen Sie Ihre gewünschte Sportart aus',
                style: TextStyle(fontSize: 25),
                textAlign: TextAlign.center,
              ),
              Text('$_event'),
              GridView.count(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                primary: false,
                padding: const EdgeInsets.all(10),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                crossAxisCount: 2,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PushUp()),
                      );
                    }, // Handle your callback
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/pushup.png"),
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                      child: Text("Liegestützen"),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PushUp()),
                      );
                    }, // Handle your callback
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/squat.png"),
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                      child: Text("Squats"),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PushUp()),
                      );
                    }, // Handle your callback
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/crunch.png"),
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                      child: Text("Crunches"),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PushUp()),
                      );
                    }, // Handle your callback
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/crunch up.png"),
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                      child: Text("Dehnung"),
                    ),
                  ),
                ],
              ),
              // start listening button
              !ESenseManager.connected
                  ? FloatingActionButton(
                      // a floating button that starts/stops listening to sensor events.
                      // is disabled until we're connected to the device.
                      onPressed: () => connectToBLEButtonEffect(context),
                      tooltip: '(Re-) Connect to Headphones',
                      child: Icon(Icons.bluetooth_searching),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}

enum SportState { pushUp, stats }

class BodyWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => BodyWidgetState();
}

class BodyWidgetState extends State<BodyWidget>
    with SingleTickerProviderStateMixin<BodyWidget> {
  SportState selectedWidgetMarker = SportState.pushUp;
  final int optimalSpeed = 8000;

  int _pushups = 0;
  List<int> timings = [];
  var previousTime;
  StreamSubscription subscription;
  bool listening = false;
  Color counterBackgroundColor = Colors.cyan[700];
  String counterText = "";

  void listenToSensors() async {
    if (!listening) {
      listening = true;
      subscription = ESenseManager.sensorEvents.listen((event) {
        List<int> acc = event.accel;
        setState(() {
          checkSpeed(acc[1]);
        });
      });
    }
  }

  void stopListening() {
    if (listening) {
      subscription.cancel();
      timings.clear();
      _pushups = 0;
      avgSpots.clear();
    }
  }

  List<int> werte = [];

  void checkSpeed(int value) {
    if (value > optimalSpeed) {
      setState(() {
        counterBackgroundColor = Colors.deepOrangeAccent;
        counterText = "\nToo Fast";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            FlatButton.icon(
              icon: Icon(Icons.swap_vert),
              onPressed: () {
                setState(() {
                  selectedWidgetMarker = SportState.pushUp;
                });
              },
              label: Text(
                "Liegestütze",
                style: TextStyle(
                    color: (selectedWidgetMarker == SportState.pushUp)
                        ? Colors.black
                        : Colors.black12),
              ),
            ),
            FlatButton.icon(
              icon: Icon(Icons.bar_chart_outlined),
              onPressed: () {
                setState(() {
                  selectedWidgetMarker = SportState.stats;
                });
              },
              label: Text("Statistik",
                  style: TextStyle(
                      color: (selectedWidgetMarker == SportState.stats)
                          ? Colors.black
                          : Colors.black12)),
            ),
          ],
        ),
        Container(
          child: getCustomContainer(width, height),
        )
      ],
    );
  }

  Widget getCustomContainer(double width, double height) {
    switch (selectedWidgetMarker) {
      case SportState.pushUp:
        return getPushUpContainer(width, height);
      case SportState.stats:
        return getStatsContainer();
    }
    return getPushUpContainer(width, height);
  }

  Widget getPushUpContainer(double width, double height) {
    return Container(
      padding: EdgeInsets.all(50),
      child: ButtonTheme(
        buttonColor: counterBackgroundColor,
        textTheme: ButtonTextTheme.primary,
        minWidth: width * 0.75,
        height: height * 0.5,
        child: RaisedButton(
          onPressed: () {
            _add();
            listenToSensors();
          },
          child: Text(
            '${_pushups}' + counterText,
            style: TextStyle(fontSize: 25),
          ),
        ),
      ),
    );
  }

  void _add() {
    counterBackgroundColor = Colors.cyan[700];
    counterText = "";
    if (_pushups == 0) {
      listenToSensors();
      previousTime = new DateTime.now();
    } else {
      var now = DateTime.now();
      var diff = now.difference(previousTime);
      timings.add(diff.inMilliseconds);
      previousTime = now;
    }
    setState(() {
      _pushups++;
    });
  }

  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];
  bool showAvg = false;
  List<FlSpot> spots = <FlSpot>[];
  List<FlSpot> avgSpots = <FlSpot>[];
  int length;

  Widget getStatsContainer() {
    double averageTiming = 0;
    LineChart chart;
    if (timings.isNotEmpty) {
      List<int> xAxis = new List<int>.generate(timings.length, (i) => i + 1);
      length = timings.length;
      for (int i = 0; i < timings.length; i++) {
        if (timings[i] / 1000 < 10.0) {
          spots.add(new FlSpot(
              xAxis[i].toDouble() - 1,
              double.parse(
                  (timings[i].toDouble() / 1000).toStringAsPrecision(2))));
        }
      }
      stopListening();
      return AspectRatio(
        aspectRatio: 1.23,
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            color: Color(0xff232d37),
          ),
          child: Stack(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(
                    height: 37,
                  ),
                  const Text(
                    'Benötigte Zeit je Liegestütze',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 37,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          right: 18.0, left: 12.0, top: 24, bottom: 12),
                      child: LineChart(
                        showAvg ? avgData() : mainData(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    height: 34,
                    child: FlatButton(
                      onPressed: () {
                        setState(() {
                          if (showAvg) spots.clear();
                          showAvg = !showAvg;
                        });
                      },
                      child: Text(
                        'Durschnittszeit',
                        style: TextStyle(
                            fontSize: 12,
                            color: !showAvg
                                ? Colors.white.withOpacity(0.5)
                                : Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return AspectRatio(
      aspectRatio: 1.23,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          color: Color(0xff232d37),
        ),
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(
                  height: 37,
                ),
                const Text(
                  'Sie müssen zuerst ein paar Liegestütze machen, um die Statistik einsehen zu können!',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          getTextStyles: (value) => const TextStyle(
              color: Color(0xff68737d),
              fontWeight: FontWeight.bold,
              fontSize: 16),
          getTitles: (value) {
            return (value.toInt() + 1).toString();
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) => const TextStyle(
            color: Color(0xff67727d),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 1:
                return '1s';
              case 3:
                return '3s';
              case 5:
                return '5s';
            }
            return '';
          },
          reservedSize: 28,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: length.toDouble() - 1,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          colors: gradientColors,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors:
                gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ],
    );
  }

  LineChartData avgData() {
    double averageTiming = timings.reduce((a, b) => a + b) / timings.length;
    List<int> xAxis = new List<int>.generate(timings.length, (i) => i + 1);
    for (int i = 0; i < timings.length; i++) {
      avgSpots.add(new FlSpot(xAxis[i].toDouble() - 1,
          double.parse((averageTiming / 1000).toStringAsPrecision(2))));
    }
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          getTextStyles: (value) => const TextStyle(
              color: Color(0xff68737d),
              fontWeight: FontWeight.bold,
              fontSize: 16),
          getTitles: (value) {
            return (value.toInt() + 1).toString();
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) => const TextStyle(
            color: Color(0xff67727d),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 1:
                return '1s';
              case 3:
                return '3s';
              case 5:
                return '5s';
            }
            return '';
          },
          reservedSize: 28,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: length.toDouble() - 1,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: avgSpots,
          isCurved: true,
          colors: [
            ColorTween(begin: gradientColors[0], end: gradientColors[1])
                .lerp(0.2),
            ColorTween(begin: gradientColors[0], end: gradientColors[1])
                .lerp(0.2),
          ],
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(show: true, colors: [
            ColorTween(begin: gradientColors[0], end: gradientColors[1])
                .lerp(0.2)
                .withOpacity(0.1),
            ColorTween(begin: gradientColors[0], end: gradientColors[1])
                .lerp(0.2)
                .withOpacity(0.1),
          ]),
        ),
      ],
    );
  }
}

class PushUp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text("Liegestütze"), backgroundColor: Colors.cyan[700]),
      body: Column(
        children: <Widget>[
          BodyWidget(),
        ],
      ),
    );
  }
}

/// Sample time series data type.
class ChartEntry {
  final int x;
  final double y;

  ChartEntry(this.x, this.y);
}
