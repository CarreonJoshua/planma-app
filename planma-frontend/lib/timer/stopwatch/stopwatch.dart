import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:planma_app/Providers/time_provider.dart';

class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});

  @override
  State<StopwatchPage> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  bool disableBackButton = false;

  @override
  Widget build(BuildContext context) {
    final timeProvider = Provider.of<TimeProvider>(context);

    return WillPopScope(
      onWillPop: () async => !disableBackButton,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Stopwatch"),
          leading: disableBackButton
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatTime(timeProvider.elapsedTime),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 60,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (timeProvider.isStopwatchRunning) {
                        timeProvider.pauseStopwatch();
                        setState(() {
                          disableBackButton = false;
                        });
                      } else {
                        timeProvider.startStopwatch();
                        setState(() {
                          disableBackButton = true;
                        });
                      }
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: Icon(
                        timeProvider.isStopwatchRunning
                            ? Icons.pause
                            : Icons.play_arrow,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      timeProvider.resetStopwatch();
                      setState(() {
                        disableBackButton = false;
                      });
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: const Icon(
                        Icons.stop,
                        size: 35,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    return "${hours.toString().padLeft(2, "0")}:${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}";
  }
}
