class PaymentModel {
  final double amount;
  final String courseName;
  final String childName;
  final DateTime date;
  final bool isPaid;

  PaymentModel({
    required this.amount,
    required this.courseName,
    required this.childName,
    required this.date,
    required this.isPaid,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {

    return PaymentModel(
      amount: double.parse(json['amount'].toString()),//12, //(json['amount'] ?? 0).toDouble(),
      courseName: json['courseName'] ?? '',
      childName: json['childName'] ?? '',
      date: DateTime.parse(json['date'].toString().replaceFirst(' ', 'T')),//DateTime.now(),//parse(json['date'].toString().replaceFirst(' ', 'T')),//parse(json['date'].toString().replaceFirst(' ', 'T')),
      isPaid: json['isPaid'] == 1 || json['isPaid'] == true,
    );
  }
}