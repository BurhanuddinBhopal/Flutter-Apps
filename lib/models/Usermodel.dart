class Item {
  final String id;
  final String name;
  final String organisationName;
  final String lastName;
  final String location;
  final double pendingAmount;
  final String mobileNumber;
  final DateTime date;
  final String type;

  Item({
    required this.id,
    required this.name,
    required this.organisationName,
    required this.lastName,
    required this.location,
    required this.pendingAmount,
    required this.mobileNumber,
    required this.date,
    required this.type,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      organisationName: json['organisationName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      location: json['location'] as String? ?? '',
      pendingAmount: (json['pendingAmount'] as num).toDouble(),
      mobileNumber: json['mobileNumber'] as String? ?? '',
      type: json['type'] ?? 'Customer',
      date:
          json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'organisationName': organisationName,
      'lastName': lastName,
      'location': location,
      'pendingAmount': pendingAmount,
      'mobileNumber': mobileNumber,
      'date': date.toIso8601String(),
    };
  }
}
