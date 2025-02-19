import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color color;

  ProgressBar({
    required this.progress,
    this.height = 8.0,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: Colors.grey[300],
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}


class Progressbar extends StatefulWidget {
  @override
  _ProgressbarState createState() => _ProgressbarState();
}

class _ProgressbarState extends State<Progressbar> {
  double progress = 0.0;

  void simulateProgress() {
    Future.delayed(Duration(milliseconds: 1000), () {
      if (progress < 1.0) {
        setState(() {
          progress += 0.1;
        });
        simulateProgress();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    simulateProgress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Progress Bar Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ProgressBar(
              progress: progress,
              height: 10.0,
              color: Colors.green,
            ),
            SizedBox(height: 20),
            Text('Progress: ${(progress * 100).toStringAsFixed(0)}%'),
          ],
        ),
      ),
    );
  }
}

