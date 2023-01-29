import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:delivery/postcode.dart';

class View extends StatefulWidget {
  const View({super.key});

  @override
  State<View> createState() => _ViewState();
}

class _ViewState extends State<View> {
  TextEditingController pickup = TextEditingController();
  TextEditingController dropOff = TextEditingController();
  var types = ["Car", "Small Van", "Medium Van", "Luton Van"];

  var selected = '';
  var priceVat = '';
  var priceWoVat = '';

  bool isLoading = false;
  bool calculated = false;

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.height *
        0.01; // Provides height of the screen
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Padding(
                padding: EdgeInsets.all(size * 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Order Creation',
                      style: TextStyle(
                          fontSize: size * 4, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: size * 4),
                    TextField(
                      decoration: InputDecoration(
                        labelText: "Pickup Postcode",
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      controller: pickup,
                    ),
                    SizedBox(height: size * 4),
                    TextField(
                      decoration: InputDecoration(
                        labelText: "Drop-off Postcode",
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      controller: dropOff,
                    ),
                    SizedBox(height: size * 4),
                    FormField<String>(
                      builder: (FormFieldState<String> state) {
                        return InputDecorator(
                          decoration: InputDecoration(
                            labelText: "Vehicle Type",
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          isEmpty: selected == '',
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selected.isNotEmpty ? selected : null,
                              isDense: true,
                              onChanged: (newValue) {
                                setState(() {
                                  selected = newValue.toString();
                                  state.didChange(newValue);
                                });
                              },
                              items: types.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: size * 4),
                    calculated
                        ? Column(
                            children: <Widget>[
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text('Price excluding VAT: ', style: TextStyle(
                                      fontSize: size * 2)),
                                  Text('£$priceWoVat', style: TextStyle(
                                      fontSize: size * 2, fontWeight: FontWeight.bold))
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text('Price including VAT: ', style: TextStyle(
                                      fontSize: size * 2)),
                                  Text('£$priceVat', style: TextStyle(
                                      fontSize: size * 2, fontWeight: FontWeight.bold))
                                ],
                              ),
                              SizedBox(height: size * 2),
                              ButtonTheme(
                                  minWidth: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height * 0.06,
                                  shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                          color: Color(0xFF052339),
                                          style: BorderStyle.solid),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: MaterialButton(
                                    elevation: 8.0,
                                    onPressed: () {
                                      _reset();
                                    },
                                    color: const Color(0xFF052339),
                                    child: Text(
                                      'Reset',
                                      style: TextStyle(
                                          fontSize: size * 2, color: Colors.white),
                                    ),
                                  )),
                            ],
                          )
                        : ButtonTheme(
                            minWidth: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.06,
                            shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: Color(0xFF052339),
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(10)),
                            child: MaterialButton(
                              elevation: 8.0,
                              onPressed: () {
                                _getLatLong(pickup.text, dropOff.text);
                              },
                              color: const Color(0xFF052339),
                              child: Text(
                                'View Pricing',
                                style: TextStyle(
                                    fontSize: size * 2, color: Colors.white),
                              ),
                            )),
                    const Spacer(),
                    const Text(
                      'Version: 3.9.3',
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  _getLatLong(pickup, dropOff) async {
    // This method gets latitude and longitude of the postcodes from open source api

    if (pickup == "") {
      showDialog(
          context: context,
          builder: (context) => const AlertDialog(
                title: Text("Missing Information"),
                content: Text("Please enter the pickup postcode"),
              ));
      return;
    }
    if (dropOff == "") {
      showDialog(
          context: context,
          builder: (context) => const AlertDialog(
                title: Text("Missing Information"),
                content: Text("Please enter the drop-off postcode"),
              ));
      return;
    }

    if (selected == "") {
      showDialog(
          context: context,
          builder: (context) => const AlertDialog(
            title: Text("Missing Information"),
            content: Text("Please select the vehicle type"),
          ));
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });
      var pickupUrl = Uri.parse('http://api.postcodes.io/postcodes/$pickup');
      var dropOffUrl = Uri.parse('http://api.postcodes.io/postcodes/$dropOff');
      final pickupResponse = await http.get(pickupUrl);
      final dropOffResponse = await http.get(dropOffUrl);

      if (pickupResponse.statusCode == 200) {
        Postcode lookup = Postcode.fromJson(json.decode(pickupResponse.body)); // JSON model to parse the response from open source postcode API
        double? pickupLat = lookup.result?.latitude;
        double? pickupLong = lookup.result?.longitude;
        if (dropOffResponse.statusCode == 200) {
          Postcode lookup =
              Postcode.fromJson(json.decode(dropOffResponse.body));
          double? dropOffLat = lookup.result?.latitude;
          double? dropOffLong = lookup.result?.longitude;
          _calculateDistance(pickupLat, pickupLong, dropOffLat, dropOffLong); // calling calculate distance method
        } else {
          setState(() {
            isLoading = false;
          });
          // ignore: use_build_context_synchronously
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Drop-Off postcode"),
                  content: const Text(
                      "The provided drop-off postcode is incorrect, please enter the correct postcode."),
                  actions: <Widget>[
                    ElevatedButton(
                        child: const Text(
                          'Ok!',
                        ),
                        onPressed: () {
                          setState(() {
                            Navigator.pop(context);
                          });
                        }),
                  ],
                );
              });
        }
      } else {
        setState(() {
          isLoading = false;
        });
        // ignore: use_build_context_synchronously
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: const Text("Pickup postcode"),
                content: const Text(
                    "The provided pickup postcode is incorrect, please enter the correct postcode."),
                actions: <Widget>[
                  ElevatedButton(
                      child: const Text(
                        'Ok!',
                      ),
                      onPressed: () {
                        setState(() {
                          Navigator.pop(context);
                        });
                      }),
                ],
              );
            });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: const Text("Error"),
              content: const Text(
                  "Failed to calculate price at this time, please try again later!"),
              actions: <Widget>[
                ElevatedButton(
                    child: const Text(
                      'Ok!',
                    ),
                    onPressed: () {
                      setState(() {
                        Navigator.pop(context);
                      });
                    }),
              ],
            );
          });
      return;
    }
  }

  _calculateDistance(pickupLat, pickupLong, dropOffLat, dropOffLong) {
    // This method takes the latitude and longitude of both postcodes and calculates the distance between them
    double distanceInMeters = Geolocator.distanceBetween(
        pickupLat, pickupLong, dropOffLat, dropOffLong);
    double distanceInMiles = distanceInMeters / 1609;
    _calculatePricing(distanceInMiles);
  }

  _calculatePricing(distanceInMiles) {
    // This method calculates the price based on the vehicle type and distance between two postcodes
    if (selected == 'Car') {
      var woVat = (distanceInMiles * 100) / 100; // price without vat converted to Pound
      var vat = woVat * 0.2; // calculate vat
      var wVat = woVat + vat; // price including vat
      priceWoVat = woVat.toStringAsFixed(2);
      priceVat = wVat.toStringAsFixed(2);
      setState(() {
        isLoading = false;
        calculated = true;
      });
      return;
    }
    if (selected == 'Small Van') {
      var woVat = (distanceInMiles * 150) / 100; // price without vat converted to Pound
      var vat = woVat * 0.2; // calculate vat
      var wVat = woVat + vat; // price including vat
      priceWoVat = woVat.toStringAsFixed(2);
      priceVat = wVat.toStringAsFixed(2);
      setState(() {
        isLoading = false;
        calculated = true;
      });
      return;
    }
    if (selected == 'Medium Van') {
      var woVat = (distanceInMiles * 180) / 100; // price without vat converted to Pound
      var vat = woVat * 0.2; // calculate vat
      var wVat = woVat + vat; // price including vat
      priceWoVat = woVat.toStringAsFixed(2);
      priceVat = wVat.toStringAsFixed(2);
      setState(() {
        isLoading = false;
        calculated = true;
      });
      return;
    }
    if (selected == 'Luton Van') {
      var woVat = (distanceInMiles * 200) / 100; // price without vat converted to Pound
      var vat = woVat * 0.2; // calculate vat
      var wVat = woVat + vat; // price including vat
      priceWoVat = woVat.toStringAsFixed(2);
      priceVat = wVat.toStringAsFixed(2);
      setState(() {
        isLoading = false;
        calculated = true;
      });
      return;
    }
  }

  _reset() {
    // This method resets the form
    setState(() {
      calculated = false;
      pickup.text = '';
      dropOff.text = '';
      selected = '';
    });
  }
}
