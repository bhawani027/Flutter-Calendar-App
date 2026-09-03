import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/di/injector.dart';
import '../features/calendar/presentation/cubit/calendar_cubit.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class CalendarApp extends StatelessWidget {
  const CalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    // The calendar cubit lives above the navigator so the event list survives
    // pushing the editor on top of it.
    return BlocProvider(
      create: (_) => sl<CalendarCubit>(),
      child: MaterialApp(
        title: 'Calendar',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        initialRoute: AppRoutes.calendar,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
