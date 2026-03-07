class OrderModel {
  final String userId;
  final String email;
  final String firstName;
  final String lastName;
  final String address;
  final String phone;
  final String city;
  final String country;
  final String paymentMethod;
  final double shippingFee;
  final double totalAmount;
  final List<Map<String, dynamic>> items;
  final DateTime timestamp;

  OrderModel({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.phone,
    required this.city,
    required this.country,
    required this.paymentMethod,
    required this.shippingFee,
    required this.totalAmount,
    required this.items,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'address': address,
      'phone': phone,
      'city': city,
      'country': country,
      'paymentMethod': paymentMethod,
      'shippingFee': shippingFee,
      'totalAmount': totalAmount,
      'items': items,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
