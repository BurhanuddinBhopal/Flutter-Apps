class Customer {
  final String name;
  final String lastName;
  final String organisationName;
  final String location;
  final int pendingAmount;
  final String mobileNumber;
  final DateTime date;
  final List<Transaction> transactions;

  Customer({
    required this.lastName,
    required this.organisationName,
    required this.name,
    required this.location,
    required this.pendingAmount,
    required this.mobileNumber,
    required this.date,
    required this.transactions, // Provide a default value here
  });

  Customer.fromMap(Map<String, dynamic> map)
      : lastName = map['lastName'],
        organisationName = map['organisationName'],
        name = map['name'],
        location = map['location'],
        pendingAmount = map['pendingAmount'],
        mobileNumber = map['mobileNumber'],
        date = DateTime.parse(map['date']),
        transactions = (map['transactions'] as List<dynamic>)
            .map((transactionMap) => Transaction.fromMap(transactionMap))
            .toList();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'lastName': lastName,
      'organisationName': organisationName,
      'location': location,
      'pendingAmount': pendingAmount,
      'mobileNumber': mobileNumber,
      'date': date.toString(), // Convert DateTime to String
      'transactions':
          transactions.map((transaction) => transaction.toMap()).toList(),
    };
  }

  @override
  String toString() {
    return 'Customer: {lastName: $lastName, name: $name, organisationName: $organisationName}';
  }
}

class Transaction {
  final DateTime date;
  final double amount;

  Transaction({required this.date, required this.amount});

  Transaction.fromMap(Map<String, dynamic> map)
      : date = DateTime.parse(map['orderPlaceHolder']['date']),
        amount = map['amount'].toDouble();

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(), // Convert DateTime to String
      'amount': amount,
    };
  }

  @override
  String toString() {
    return 'Transaction: {date: $date, amount: $amount}';
  }
}

// class Transaction {
//   final String description;
//   final double amount;
//   final DateTime date;

//   Transaction(
//       {required this.description, required this.amount, required this.date});
// }
