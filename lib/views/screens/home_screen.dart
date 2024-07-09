import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:lesson_52/services/location_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
                              
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController myController;
  final _controller = TextEditingController();
  final String googleApiKey = "AIzaSyBEjfX9jrWudgRcWl2scld4R7s0LtlaQmQ";
  LatLng myCurrentPosition = const LatLng(41.2856806, 69.2034646);
  Set<Marker> myMarkers = {};
  Set<Polyline> polylines = {};
  List<LatLng> myPositions = [];

  void _onMapCreated(GoogleMapController controller) {
    myController = controller;
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await LocationService.getCurrentLocation();
    });
  }

  void onCameraMove(CameraPosition position) {
    setState(() {
      myCurrentPosition = position.target;
    });
  }

  void watchMyLocation() {
    LocationService.getLiveLocation().listen((location) {
      setState(() {
        myCurrentPosition = LatLng(location.latitude!, location.longitude!);
      });
    });
  }

  void _addLocationMarker() {
    myMarkers.add(
      Marker(
        markerId: MarkerId(UniqueKey().toString()),
        position: myCurrentPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ),
    );
    myPositions.add(myCurrentPosition);

    if (myPositions.length == 2) {
      LocationService.fetchPolylinePoints(
        myPositions[0],
        myPositions[1],
      ).then((List<LatLng> positions) {
        polylines.add(
          Polyline(
            polylineId: PolylineId(UniqueKey().toString()),
            color: Colors.blue,
            width: 5,
            points: positions,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.satellite,
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: myCurrentPosition,
              zoom: 18.0,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('myCurrentPosition'),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue,
                ),
                position: myCurrentPosition,
                infoWindow: const InfoWindow(
                  title: "My Position",
                ),
              ),
              ...myMarkers,
            },
            onCameraMove: onCameraMove,
            polylines: polylines,
          ),
          Positioned(
            top: 90,
            left: 15,
            right: 15,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white60,
                borderRadius: BorderRadius.circular(15),
              ),
              child: GooglePlacesAutoCompleteTextFormField(
                textEditingController: _controller,
                googleAPIKey: googleApiKey,
                decoration: InputDecoration(
                  hintText: "search...",
                  contentPadding: const EdgeInsets.all(10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                getPlaceDetailWithLatLng: (postalCodeResponse) async {
                  await myController.animateCamera(
                    CameraUpdate.newLatLng(
                      LatLng(
                        double.parse(postalCodeResponse.lat!),
                        double.parse(postalCodeResponse.lng!),
                      ),
                    ),
                  );
                  setState(() {
                    myCurrentPosition = LatLng(
                      double.parse(postalCodeResponse.lat!),
                      double.parse(postalCodeResponse.lng!),
                    );
                  });
                },
                itmClick: (postalCodeResponse) {
                  _controller.text = postalCodeResponse.description!;
                  _controller.selection = TextSelection.fromPosition(
                    TextPosition(
                      offset: postalCodeResponse.description!.length,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _addLocationMarker,
        child: const Icon(
          Icons.add_location_alt,
          size: 35,
        ),
      ),
    );
  }
}
