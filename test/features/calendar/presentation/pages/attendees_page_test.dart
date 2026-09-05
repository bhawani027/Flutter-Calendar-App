import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mycalendar_app/features/calendar/domain/entities/attendee.dart';
import 'package:mycalendar_app/features/calendar/presentation/cubit/attendees_cubit.dart';
import 'package:mycalendar_app/features/calendar/presentation/pages/attendees_page.dart';

import '../../../../helpers/pump_page.dart';

void main() {
  configureWidgetTests();

  const asha = Attendee(name: 'Asha', email: 'asha@haineo.org');

  Widget subject([List<Attendee> initial = const []]) => BlocProvider(
        create: (_) => AttendeesCubit(initial),
        child: const AttendeesPage(),
      );

  Future<void> typePerson(
    WidgetTester tester,
    String name,
    String email,
  ) async {
    await tester.enterText(find.widgetWithText(TextField, 'Name'), name);
    await tester.enterText(find.widgetWithText(TextField, 'Email'), email);
  }

  testWidgets('shows an empty message when nobody is invited', (tester) async {
    await tester.pumpPage(subject());

    expect(find.text('Nobody invited yet.'), findsOneWidget);
  });

  testWidgets('lists the people it was given', (tester) async {
    await tester.pumpPage(subject([asha]));

    expect(find.text('Asha'), findsOneWidget);
    expect(find.text('asha@haineo.org'), findsOneWidget);
    expect(find.text('Nobody invited yet.'), findsNothing);
  });

  testWidgets('adding a person lists them and clears the fields',
      (tester) async {
    await tester.pumpPage(subject());

    await typePerson(tester, 'Asha', 'asha@haineo.org');
    await tester.tap(find.text('Add person'));
    await tester.pumpAndSettle();

    expect(find.text('asha@haineo.org'), findsOneWidget);
    final nameField = tester.widget<TextField>(
      find.widgetWithText(TextField, 'Name'),
    );
    expect(nameField.controller!.text, isEmpty);
  });

  testWidgets('a bad email shows the error and adds nobody', (tester) async {
    await tester.pumpPage(subject());

    await typePerson(tester, 'Asha', 'not-an-email');
    await tester.tap(find.text('Add person'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a valid email address.'), findsOneWidget);
    expect(find.text('Nobody invited yet.'), findsOneWidget);
  });

  testWidgets('a missing name shows the error', (tester) async {
    await tester.pumpPage(subject());

    await typePerson(tester, '', 'asha@haineo.org');
    await tester.tap(find.text('Add person'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a name.'), findsOneWidget);
  });

  testWidgets('removing a person drops them from the list', (tester) async {
    await tester.pumpPage(subject([asha]));

    await tester.tap(find.byTooltip('Remove Asha'));
    await tester.pumpAndSettle();

    expect(find.text('Asha'), findsNothing);
    expect(find.text('Nobody invited yet.'), findsOneWidget);
  });

  testWidgets('backing out returns the edited list to the caller',
      (tester) async {
    List<Attendee>? returned;

    await tester.pumpPage(
      Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async {
            returned = await Navigator.of(context).push<List<Attendee>>(
              MaterialPageRoute(builder: (_) => subject()),
            );
          },
          child: const Text('open'),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await typePerson(tester, 'Asha', 'asha@haineo.org');
    await tester.tap(find.text('Add person'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(returned, [asha]);
  });
}
