# Flutter Calendar App

A calendar app built with Flutter, structured with **Clean Architecture** and
`flutter_bloc`. Create, edit and delete events, view them by schedule / day /
week / month, invite people, attach a location and a time zone, and have it all
survive a restart.

## Getting started

```bash
flutter pub get
flutter run
```

Requires Flutter 3.29+ (Dart SDK 3.9+).

## Architecture

Three layers per feature, with dependencies pointing inward only:

```
presentation  ->  domain  <-  data
   (cubits)      (entities,     (models,
                  use cases,     data sources,
                  contracts)     implementations)
```

The **domain** layer is pure Dart — no Flutter, no Hive, no Syncfusion. It owns
the entities, the repository *interfaces*, and the use cases. The **data** layer
implements those interfaces. The **presentation** layer talks only to use cases.

Because the arrows point inward, the storage engine, the calendar widget and the
UI can each be replaced without touching the business rules.

```
lib/
├── main.dart                     # bootstrap: DI, then runApp
├── app/                          # MaterialApp, routes, theme
│   ├── app.dart
│   ├── router/app_router.dart
│   └── theme/
├── core/                         # shared across features
│   ├── di/injector.dart          # get_it registrations
│   ├── error/                    # exceptions (data) + failures (domain)
│   ├── usecase/usecase.dart      # UseCase / StreamUseCase contracts
│   ├── presentation/             # LoadStatus, shared error snack bar
│   ├── extensions/
│   └── utils/id_generator.dart
└── features/
    ├── calendar/                 # the main feature
    │   ├── domain/
    │   │   ├── entities/         # CalendarEvent, Attendee, RecurrenceRule
    │   │   ├── repositories/     # EventRepository (interface)
    │   │   └── usecases/         # Watch/GetInRange/Create/Update/Delete
    │   ├── data/
    │   │   ├── models/           # JSON-serialisable versions of the entities
    │   │   ├── datasources/      # EventLocalDataSource + Hive implementation
    │   │   └── repositories/     # EventRepositoryImpl
    │   └── presentation/
    │       ├── cubit/            # Calendar, EventEditor, Attendees
    │       ├── pages/            # CalendarPage, EventEditorPage, AttendeesPage
    │       └── widgets/
    ├── timezone/                 # IANA time zone picker (same three layers)
    └── location/                 # device location picker (same three layers)
```

### Where the rules live

`CalendarEvent.validate()` and `CalendarEvent.normalized()` hold what makes an
event valid and what `isAllDay` means (midnight to 23:59:59.999999). Both save
use cases call them, so the rules hold for every caller rather than only for
events built by the editor screen.

The editor edits a `CalendarEvent` with `copyWith` instead of mirroring its
fields in form state, so a field the form does not render survives a save.

### Error handling

Data sources throw exceptions. Repositories catch them and return
`Either<Failure, T>` (from `fpdart`) — `Right` is success, `Left` is a
`Failure`. Nothing above the repository catches exceptions; errors are values
all the way to the cubit, which turns them into a message on screen.

### Dependency injection

`get_it`, wired by hand in `lib/core/di/injector.dart`. Repositories and use
cases are lazy singletons; cubits are factories so each screen gets its own.
No code generation.

### Storage

Events are stored as one JSON document per event in a Hive box, keyed by id.
`EventRepositoryImpl.watchEvents()` re-reads the box whenever it changes, so the
calendar updates itself after every write with no manual refresh.

## Testing

```bash
flutter test
flutter analyze
```

113 tests cover all three layers of all three features: the entities
(validation and normalisation), the JSON mapping, the use cases, the
repositories' exception-to-failure translation, every cubit, and widget tests
that drive the three pages through their cubits. The domain and data layers need no Flutter bindings; every dependency is
faked through its interface with `mocktail`.
