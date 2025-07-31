import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:map_location_picker/map_location_picker.dart';
class Addlocation extends StatefulWidget {
  const Addlocation({super.key});

  @override
  State<Addlocation> createState() => _AddlocationState();
}

class _AddlocationState extends State<Addlocation> {
  Position? _currentLocation;
  late bool servicePermission = false;
  late LocationPermission permission;

  String _currentAddress = "";
  Future<Position>_getCurrentLocation() async{
    servicePermission = await Geolocator.isLocationServiceEnabled();
    if(!servicePermission){
      permission= await Geolocator.checkPermission();
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: Text("Add Location"),
        centerTitle: true,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(CupertinoIcons.chevron_back)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Location Coordinates"),
            Text("Coordinates"),
            Text("Location Address"),
            SizedBox(height: 40,),
            ElevatedButton(onPressed: ()async{
              _currentLocation = await _getCurrentLocation();
              print("$_currentLocation");
            }, child: Text("Current Location ")),
          ],
        ),
      ),
    );
  }
}
