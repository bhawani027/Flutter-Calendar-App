import 'package:flutter/material.dart';

/// A named colour an event can be tagged with.
class EventColor {
  const EventColor(this.name, this.value);

  final String name;
  final int value;

  Color get color => Color(value);
}

/// The palette offered by the colour picker.
///
/// Same nine colours as before, with the labels split apart (they used to be
/// one concatenated string) and the malformed grey `0xFF63636` corrected.
abstract final class AppColors {
  static const List<EventColor> eventPalette = [
    EventColor('Green', 0xFF0F8644),
    EventColor('Purple', 0xFF8B1FA9),
    EventColor('Red', 0xFFD20100),
    EventColor('Orange', 0xFFFC571D),
    EventColor('Caramel', 0xFF85461E),
    EventColor('Magenta', 0xFFFF00FF),
    EventColor('Blue', 0xFF3D4FB5),
    EventColor('Peach', 0xFFE47C73),
    EventColor('Gray', 0xFF636363),
  ];

  static const Color seed = Color(0xFF0F8644);

  /// The label for a stored colour value, for display in the editor.
  ///
  /// Every colour the app can assign is in [eventPalette] — including
  /// `CalendarEvent.defaultColorValue` — so an unknown value means data from
  /// an older build.
  static String nameOf(int value) => eventPalette
      .firstWhere(
        (entry) => entry.value == value,
        orElse: () => const EventColor('Custom', 0),
      )
      .name;
}
