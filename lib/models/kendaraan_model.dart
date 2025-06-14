class Vehicle {
  String name;
  String lastServiceDate;
  int mileage;

  Vehicle({required this.name, required this.lastServiceDate, required this.mileage});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lastServiceDate': lastServiceDate,
      'mileage': mileage,
    };
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      name: json['name'],
      lastServiceDate: json['lastServiceDate'],
      mileage: json['mileage'],
    );
  }
}
