import 'package:flutter/material.dart';

/// Helper widget to test animated children,
/// e.g. effected by time-dependant shader.
class RebuildEachFrame extends StatelessWidget {
  final WidgetBuilder builder;

  const RebuildEachFrame({Key? key, required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      /// 20 years should be enough.
      duration: const Duration(days: 365 * 20),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, _, __) => builder(context),
    );
  }
}
