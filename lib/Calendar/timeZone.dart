import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class timezone extends StatefulWidget {
  const timezone({super.key});

  @override
  State<timezone> createState() => _timezoneState();
}

class _timezoneState extends State<timezone> {
  String _selectedTimeZone = 'Asia/Kathmandu'; // Default timezone: Nepal Time (NPT)
  List<String> _allTimeZones = tz.timeZoneDatabase.locations.keys.toList();
  List<String> _filteredTimeZones = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredTimeZones = _allTimeZones;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterTimeZones(String query) {
    query = query.toLowerCase();
    setState(() {
      _filteredTimeZones = _allTimeZones.where((timezone) {
        return timezone.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(

            children: <Widget>[
        Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _searchController,
          onChanged: _filterTimeZones,
          decoration: InputDecoration(
            labelText: 'Search Timezone',
            hintText: 'Enter a timezone',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
      ),
      Expanded(
        child: ListView.builder(
          itemCount: _filteredTimeZones.length,
          itemBuilder: (context, index) {
            final timeZone = _filteredTimeZones[index];
            final location = tz.getLocation(timeZone);
            final currentTime = tz.TZDateTime.now(location);
            final offset = currentTime.timeZoneOffset;
            return ListTile(
              title: Text('$timeZone - ${currentTime.toString()} (GMT${offset.isNegative ? '' : '+'}${offset.inHours}:${(offset.inMinutes % 60).toString().padLeft(2, '0')})'),
              onTap: () {
                setState(() {
                  _selectedTimeZone = timeZone;
                });
              },
            );
          },
        ),
      ),
    ])
    );

  }
}


