import 'dart:async';

import 'package:location/location.dart';
import 'package:orange_julep/datamodels/user_location.dart';

class LocationServices {
  UserLocation _currentLocation;

  Location location = Location();

  StreamController<UserLocation> _locationController =
    StreamController<UserLocation>.broadcast();

  Stream<UserLocation> get locationStream => _locationController.stream;
  LocationService() {
    // Request permission to use location
    location.requestPermission().then((granted) {
      if (granted) {
        // If granted listen to the onLocationChanged stream and emit over our controller
        location.onLocationChanged().listen((locationData) {
          if (locationData != null) {
            _locationController.add(UserLocation(
              latitude: locationData.latitude,
              longitude: locationData.longitude,
            ));
          }
        });
      }
    });
  }


  Future<UserLocation> getLocation() async {
    try {
      var userLocation = await location.getLocaion();
      _currentLocation = UserLocation(latitude: userLocation.latitude,
      longitude: userLocation.longitude,
      );
    } catch(e){
      print('Could not get the location $e');

    }

    return _currentLocation;
  }
}