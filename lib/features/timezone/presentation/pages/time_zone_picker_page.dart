import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/load_status.dart';
import '../cubit/time_zone_cubit.dart';

/// Search the IANA time zone list. Pops the selected zone id.
class TimeZonePickerPage extends StatefulWidget {
  const TimeZonePickerPage({super.key});

  @override
  State<TimeZonePickerPage> createState() => _TimeZonePickerPageState();
}

class _TimeZonePickerPageState extends State<TimeZonePickerPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TimeZoneCubit>().search();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Time zone')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: context.read<TimeZoneCubit>().search,
              decoration: const InputDecoration(
                labelText: 'Search',
                hintText: 'e.g. Kathmandu',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<TimeZoneCubit, TimeZoneState>(
              builder: (context, state) {
                if (state.status == LoadStatus.failure) {
                  return Center(child: Text(state.errorMessage!));
                }
                if (state.zones.isEmpty) {
                  return Center(
                    child: Text(
                      state.status == LoadStatus.ready
                          ? 'No time zone matches "${state.query}".'
                          : 'Loading time zones…',
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: state.zones.length,
                  itemBuilder: (context, index) {
                    final zone = state.zones[index];
                    return ListTile(
                      title: Text(zone.id),
                      subtitle: Text(
                        '${zone.abbreviation} · ${zone.formattedOffset}',
                      ),
                      onTap: () => Navigator.of(context).pop(zone.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
