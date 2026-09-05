import 'package:flutter_test/flutter_test.dart';
import 'package:mycalendar_app/core/error/failures.dart';
import 'package:mycalendar_app/features/calendar/domain/entities/attendee.dart';

void main() {
  group('validate', () {
    test('accepts a well-formed person', () {
      expect(
        const Attendee(name: 'Asha', email: 'asha@haineo.org').validate(),
        isNull,
      );
    });

    test('rejects a blank or whitespace-only name', () {
      expect(
        const Attendee(name: '  ', email: 'asha@haineo.org').validate(),
        isA<ValidationFailure>(),
      );
    });

    test('rejects an address without a user, host, or dotted domain', () {
      for (final bad in ['asha', 'asha@', '@haineo.org', 'asha@haineo', '']) {
        expect(
          Attendee(name: 'Asha', email: bad).validate(),
          isA<ValidationFailure>(),
          reason: 'should reject "$bad"',
        );
      }
    });

    test('accepts addresses with plus tags and subdomains', () {
      for (final good in ['a+tag@haineo.org', 'a@mail.haineo.org']) {
        expect(
          Attendee(name: 'Asha', email: good).validate(),
          isNull,
          reason: 'should accept "$good"',
        );
      }
    });
  });

  test('normalized trims both fields', () {
    const messy = Attendee(name: '  Asha  ', email: '  asha@haineo.org  ');

    expect(
      messy.normalized(),
      const Attendee(name: 'Asha', email: 'asha@haineo.org'),
    );
  });

  test('is compared by value', () {
    expect(
      const Attendee(name: 'Asha', email: 'a@haineo.org'),
      const Attendee(name: 'Asha', email: 'a@haineo.org'),
    );
  });
}
