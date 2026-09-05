import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mycalendar_app/app/theme/app_theme.dart';

/// Call once per widget-test file.
///
/// Without this, the themed pages try to fetch their font over the network
/// during the test and log a failure for every pump.
void configureWidgetTests() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
}

/// Pumps [child] inside the real app theme on a roomy surface.
///
/// The generous default size keeps the test font (which is much wider than the
/// real one) from overflowing layouts that are fine on a device.
extension PumpPage on WidgetTester {
  Future<void> pumpPage(
    Widget child, {
    Size size = const Size(1200, 2000),
    NavigatorObserver? observer,
    bool settle = true,
  }) async {
    view.physicalSize = size;
    view.devicePixelRatio = 1.0;
    addTearDown(view.resetPhysicalSize);
    addTearDown(view.resetDevicePixelRatio);

    await pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        navigatorObservers: [?observer],
        home: child,
      ),
    );
    // A progress indicator never stops animating, so settling would time out.
    if (settle) {
      await pumpAndSettle();
    } else {
      await pump();
    }
  }
}
