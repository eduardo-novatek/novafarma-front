
class AddressObject {
  String? street;
  int? portNumber;
  String? betweenStreet1;
  String? betweenStreet2;
  double? lat;
  double? lon;

  AddressObject.empty():
      street = null, portNumber = 0, betweenStreet1 = null,
        betweenStreet2 = null, lat = 0, lon = 0;

  AddressObject({
      required this.street,
      required this.portNumber,
      required this.betweenStreet1,
      required this.betweenStreet2,
      this.lat,
      this.lon
  });

   factory AddressObject.fromJson(Map<String, dynamic> json) {
    return AddressObject(
      street: json['street'],
      portNumber: json['portNumber'],
      betweenStreet1: json['betweenStreet1'],
      betweenStreet2: json['betweenStreet2'],
    );
  }


}