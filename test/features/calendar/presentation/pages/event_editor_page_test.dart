import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mycalendar_app/core/error/failures.dart';
import 'package:mycalendar_app/features/calendar/domain/entities/calendar_event.dart';
import 'package:mycalendar_app/features/calendar/presentation/cubit/event_editor_cubit.dart';
import 'package:mycalendar_app/features/calendar/presentation/pages/event_editor_page.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_page.dart';

void main() {
  configureWidgetTests();

  late MockCreateEvent createEvent;
  late MockUpdateEvent updateEvent;
  late List<String> deleted;

  setUpAll(registerCommonFallbacks);

  setUp(() {
    createEvent = MockCreateEvent();
    updateEvent = MockUpdateEvent();
    deleted = [];
    when(() => createEvent(any())).thenAnswer((_) async => Right(buildEvent()));
    when(() => updateEvent(any())).thenAnswer((_) async => Right(buildEvent()));
  });

  Widget subject({CalendarEvent? existing}) => BlocProvider(
    create: (_) => EventEditorCubit(
      createEvent: createEvent,
      updateEvent: updateEvent,
      existing: existing,
      initialDate: DateTime(2026, 9, 3, 9),
    ),
    child: EventEditorPage(onDelete: (id) async => deleted.add(id)),
  );

  group('adding', () {
    testWidgets('shows the add affordances and no delete', (tester) async {
      await tester.pumpPage(subject());

      expect(find.text('Add event'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('starts empty with the placeholder fields', (tester) async {
      await tester.pumpPage(subject());

      expect(find.text('Nobody invited yet'), findsOneWidget);
      expect(find.text('No location'), findsOneWidget);
      expect(find.text('Device time zone'), findsOneWidget);
      expect(find.text('Does not repeat'), findsOneWidget);
    });

    testWidgets('a title and Add saves the event', (tester) async {
      await tester.pumpPage(subject());

      await tester.enterText(find.byType(TextField).first, 'Standup');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      final saved =
          verify(() => createEvent(captureAny())).captured.single
              as CalendarEvent;
      expect(saved.title, 'Standup');
    });

    testWidgets('a rejected save shows the reason and stays on the form', (
      tester,
    ) async {
      when(() => createEvent(any())).thenAnswer(
        (_) async => const Left(ValidationFailure('Give the event a title.')),
      );

      await tester.pumpPage(subject());
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(find.text('Give the event a title.'), findsOneWidget);
      expect(find.text('Add event'), findsOneWidget);
    });

    testWidgets('the all-day switch hides the time buttons', (tester) async {
      await tester.pumpPage(subject());

      // Starts and Ends each show a date button and a time button.
      expect(find.byType(OutlinedButton), findsNWidgets(4));

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // All-day: the dates remain, the times are gone.
      expect(find.byType(OutlinedButton), findsNWidgets(2));
    });
  });

  group('editing', () {
    testWidgets('pre-fills the stored event and offers delete', (tester) async {
      await tester.pumpPage(
        subject(
          existing: buildEvent(title: 'Retro', location: 'Pokhara'),
        ),
      );

      expect(find.text('Edit event'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Retro'), findsOneWidget);
      expect(find.text('Pokhara'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('delete asks first and does nothing when cancelled', (
      tester,
    ) async {
      await tester.pumpPage(subject(existing: buildEvent()));

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      expect(find.text('Delete event?'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(deleted, isEmpty);
    });

    testWidgets('confirming delete removes the event', (tester) async {
      await tester.pumpPage(subject(existing: buildEvent(id: 'event-7')));

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(deleted, ['event-7']);
    });

    testWidgets('Save updates rather than creating', (tester) async {
      await tester.pumpPage(subject(existing: buildEvent()));

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      verify(() => updateEvent(any())).called(1);
      verifyNever(() => createEvent(any()));
    });
  });
}
