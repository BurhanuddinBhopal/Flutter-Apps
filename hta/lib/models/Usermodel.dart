class Item {
  final int id;
  final String name;
  final String organisationName;
  final String lastName;
  final String location;
  final int pendingAmount;
  final String mobileNumber;
  final DateTime date;

  Item({
    required this.id,
    required this.name,
    required this.organisationName,
    required this.lastName,
    required this.location,
    required this.pendingAmount,
    required this.mobileNumber,
    required this.date,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      organisationName: json['organisationName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      location: json['location'] as String? ?? '',
      pendingAmount: json['pendingAmount'] as int? ?? 0,
      mobileNumber: json['mobileNumber'] as String? ?? '',
      date:
          json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
    );
  }
}
