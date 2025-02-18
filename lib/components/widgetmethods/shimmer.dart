import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatelessWidget {
  final double height;
  final double width;
  final Color baseColor;
  final Color highlightColor;
  final Widget? child;

  const ShimmerWidget({
    Key? key,
    this.height =20.0,
    this.width = double.infinity,
    this.baseColor = Colors.grey,
    this.highlightColor = Colors.white,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: child ??
          Container(
            height: height,
            width: width,
            color: Colors.white,
          ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SHIMMER')
      ),
      body: ListView.builder(
        itemCount: 13,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ShimmerWidget(
              height:50,baseColor: Color(0xFFE0E0E0),
              width: double.infinity,
            ),
          );
        },
      ),
    );
  }
}
