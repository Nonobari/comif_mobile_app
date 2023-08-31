import 'package:flutter/material.dart';
import 'dart:async';

class CountdownTimer extends StatefulWidget {
  const CountdownTimer({Key? key}) : super(key: key);
  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  DateTime _nextthursday = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Calculate the next thursday at 6 PM
    _nextthursday = _calculateNextthursday();

    // Set up a timer to update the countdown every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Calculate the remaining time until the next thursday at 6 PM
      Duration remainingTime = _nextthursday.difference(DateTime.now());
      if (remainingTime.inSeconds <= 0) {
        // Reset the timer for the next thursday
        _nextthursday = _calculateNextthursday();
        setState(() {});
      } else {
        setState(() {});
      }
    });
  }

  DateTime _calculateNextthursday() {
    DateTime now = DateTime.now();
    int daysUntilNextthursday = (DateTime.thursday - now.weekday + 7) % 7;
    DateTime nextthursday = DateTime(
      now.year,
      now.month,
      now.day + daysUntilNextthursday,
      18, // 6 PM
      0,
      0,
    );
    return nextthursday;
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the remaining time until the next thursday at 6 PM
    Duration remainingTime = _nextthursday.difference(DateTime.now());

    // If it's past 12 PM on thursday, show 0, otherwise show the remaining time
    Widget buildTime() {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      if (remainingTime.inSeconds <= 0 &&
          DateTime.now().weekday == DateTime.thursday) {
        remainingTime = Duration();
      } else {
        final nextthursday = _calculateNextthursday();
        remainingTime = nextthursday.difference(DateTime.now());
      }
      final days = twoDigits(remainingTime.inDays);
      final hours =
          twoDigits(remainingTime.inHours - 24 * remainingTime.inDays);
      final minutes = twoDigits(remainingTime.inMinutes.remainder(60));
      final seconds = twoDigits(remainingTime.inSeconds.remainder(60));
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildTimeCard(time: days, header: 'jours'),
          const SizedBox(width: 8),
          buildTimeCard(time: hours, header: 'heures'),
          const SizedBox(width: 8),
          buildTimeCard(time: minutes, header: 'min'),
          const SizedBox(width: 8),
          buildTimeCard(time: seconds, header: 'sec'),
        ],
      );
    }

    return Center(
      child: buildTime(),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Widget buildTimeCard({required String time, required String header}) =>
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            width: 70,
            decoration: BoxDecoration(
                gradient: const RadialGradient(colors: [
                  Color.fromARGB(255, 246, 221, 166),
                  Color.fromARGB(255, 255, 198, 76),
                ]),
                color: const Color.fromARGB(255, 246, 221, 166),
                borderRadius: BorderRadius.circular(20)),
            child: Center(
              child: Text(
                time,
                style: const TextStyle(
                    fontSize: 50,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(header, style: const TextStyle(fontSize: 24)),
        ],
      );
}
