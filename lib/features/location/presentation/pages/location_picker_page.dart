import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/location_cubit.dart';

/// Resolves the device's current location. Pops the chosen `Place`.
class LocationPickerPage extends StatelessWidget {
  const LocationPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Location')),
      body: BlocBuilder<LocationCubit, LocationState>(
        builder: (context, state) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state.isLoading)
                    const CircularProgressIndicator()
                  else if (state.place != null) ...[
                    Text(
                      state.place!.displayName,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(state.place!.coordinates),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () =>
                          Navigator.of(context).pop(state.place),
                      child: const Text('Use this location'),
                    ),
                  ] else if (state.errorMessage != null)
                    Text(
                      state.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    )
                  else
                    const Text('Find where you are to attach it to the event.'),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: state.isLoading
                        ? null
                        : context.read<LocationCubit>().locate,
                    icon: const Icon(Icons.my_location),
                    label: const Text('Current location'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
