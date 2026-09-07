import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mycalendar_app/features/calendar/domain/entities/attendee.dart';
import 'package:mycalendar_app/features/calendar/presentation/cubit/attendees_cubit.dart';

void main() {
  const asha = Attendee(name: 'Asha', email: 'asha@haineo.org');
  const bikash = Attendee(name: 'Bikash', email: 'bikash@haineo.org');

  AttendeesCubit build([List<Attendee> initial = const []]) =>
      AttendeesCubit(initial);

  test('starts from the list it was given', () {
    expect(build([asha]).state.attendees, [asha]);
  });

  group('add', () {
    test('appends the typed person and clears the row', () {
      final cubit = build()
        ..nameChanged('Asha')
        ..emailChanged('asha@haineo.org');

      expect(cubit.add(), isTrue);
      expect(cubit.state.attendees, [asha]);
      expect(cubit.state.name, isEmpty);
      expect(cubit.state.email, isEmpty);
    });

    test('trims surrounding whitespace', () {
      final cubit = build()
        ..nameChanged('  Asha  ')
        ..emailChanged('  asha@haineo.org  ');
      cubit.add();

      expect(cubit.state.attendees.single, asha);
    });

    test('rejects a blank name and keeps what was typed', () {
      final cubit = build()..emailChanged('asha@haineo.org');

      expect(cubit.add(), isFalse);
      expect(cubit.state.errorMessage, 'Please enter a name.');
      expect(cubit.state.attendees, isEmpty);
      expect(cubit.state.email, 'asha@haineo.org');
    });

    test('rejects a malformed email', () {
      for (final bad in ['asha', 'asha@', '@haineo.org', 'asha@haineo']) {
        final cubit = build()
          ..nameChanged('Asha')
          ..emailChanged(bad);

        expect(cubit.add(), isFalse, reason: 'should reject "$bad"');
        expect(cubit.state.errorMessage, 'Please enter a valid email address.');
      }
    });

    test('appends rather than replacing', () {
      final cubit = build([asha])
        ..nameChanged('Bikash')
        ..emailChanged('bikash@haineo.org');
      cubit.add();

      expect(cubit.state.attendees, [asha, bikash]);
    });
  });

  blocTest<AttendeesCubit, AttendeesState>(
    'typing clears a standing error',
    build: build,
    act: (cubit) {
      cubit.add(); // fails: nothing typed
      cubit.nameChanged('Asha');
    },
    verify: (cubit) => expect(cubit.state.errorMessage, isNull),
  );

  test('removeAt drops the right person', () {
    final cubit = build([asha, bikash])..removeAt(0);

    expect(cubit.state.attendees, [bikash]);
  });
}
