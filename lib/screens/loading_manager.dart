import 'package:flutter/material.dart%20';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingManager extends StatelessWidget {
  const LoadingManager({Key? key, required this.isloading, required this.child})
      : super(key: key);
  final bool isloading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        isloading
            ? Container(
                color: Colors.black.withOpacity(0.7),
              )
            : Container(),
        isloading
            ? const Center(
                child: SpinKitFadingCircle(
                  color: Colors.white,
                  size: 50.0,
                ),
              )
            : Container(),
      ],
    );
  }
}
