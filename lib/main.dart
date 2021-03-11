import 'package:flutter/material.dart';
import 'dart:async';
import 'package:usage_stats/usage_stats.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<UsageInfo> events = [];
  Map<String, UsageInfo> eventsMap = Map();

  @override
  void initState() {
    super.initState();
    initUsage();
  }

  Future<void> initUsage() async {
    eventsMap.clear();
    UsageStats.grantUsagePermission();
    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(Duration(hours: 1));

    Map<String, UsageInfo> queryEvents =
        await UsageStats.queryAndAggregateUsageStats(startDate, endDate);
    // queryEvents.forEach((i, value) {
    //   DateTime date = new DateTime.fromMillisecondsSinceEpoch(
    //       int.parse(value.totalTimeInForeground) * 10000);

    //   var formattedDate = DateFormat.Hm().format(date); // Apr 8, 2020
    //   print(formattedDate);
    // });
    this.setState(() {
      eventsMap = queryEvents;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Usage Stats - " + "1 Hour"),
        ),
        body: Container(
            child: ListView.separated(
          itemBuilder: (context, index) {
            String key = eventsMap.keys.elementAt(index);
            DateTime date = new DateTime.fromMillisecondsSinceEpoch(
                int.parse(eventsMap[key].totalTimeInForeground) * 1000);
            DateTime date2 = new DateTime.fromMillisecondsSinceEpoch(
                int.parse(eventsMap[key].lastTimeUsed));
            var formattedDate = DateFormat.Hms().format(date);
            return ListTile(
              title: Text(eventsMap[key].packageName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Last_Time used - " + date2.toString()),
                  Text("Total_Time In Foreground - " + formattedDate),
                ],
              ),
            );
          },
          separatorBuilder: (context, index) => Divider(),
          itemCount: eventsMap.length,
        )),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            initUsage();
          },
          child: Icon(
            Icons.refresh,
          ),
          mini: true,
        ),
      ),
    );
  }
}
