import 'package:flutter/widgets.dart';

/// Desktop-first responsive breakpoints for the SaaS dashboard shell.
/// Deliberately not flutter_screenutil: that package scales a mobile
/// design reference size, which fights a layout built around a fixed
/// sidebar + toolbar rather than a phone screen.
class Breakpoints {
  Breakpoints._();

  static const mobile = 640.0;
  static const tablet = 1024.0;
  static const desktop = 1280.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobile;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobile && width < tablet;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tablet;
}

/// Builds a different widget per breakpoint, falling back to the next
/// smaller variant provided when a larger one is omitted.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;
  final WidgetBuilder? desktop;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= Breakpoints.tablet) {
      return (desktop ?? tablet ?? mobile)(context);
    }
    if (width >= Breakpoints.mobile) {
      return (tablet ?? mobile)(context);
    }
    return mobile(context);
  }
}
