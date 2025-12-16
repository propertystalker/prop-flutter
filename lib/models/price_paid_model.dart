import 'package:intl/intl.dart';

class PricePaidModel {
  final String transactionId;
  final int amount;
  final DateTime transactionDate;
  final String propertyType;
  final String fullAddress;
  // 1. Add the paon field to the model
  final String? paon;

  PricePaidModel({
    required this.transactionId,
    required this.amount,
    required this.transactionDate,
    required this.propertyType,
    required this.fullAddress,
    // 2. Add paon to the constructor
    required this.paon,
  });

  static String _getPropertyType(String? typeUrl) {
    if (typeUrl == null || typeUrl.isEmpty) return 'Unknown';
    try {
      final uri = Uri.parse(typeUrl);
      final lastSegment = uri.pathSegments.last.replaceAll('-', ' ');
      return lastSegment[0].toUpperCase() + lastSegment.substring(1);
    } catch (e) {
      return 'Unknown';
    }
  }

  factory PricePaidModel.fromJson(Map<String, dynamic> json) {
    final address = json['propertyAddress'] as Map<String, dynamic>? ?? {};
    final paon = address['paon'] as String? ?? '';
    final saon = address['saon'] as String? ?? '';
    final street = address['street'] as String? ?? '';
    final locality = address['locality'] as String? ?? '';
    final town = address['town'] as String? ?? '';
    final district = address['district'] as String? ?? '';
    final county = address['county'] as String? ?? '';

    final addressParts = [saon, paon, street, locality, town, district, county]
        .where((part) => part.isNotEmpty)
        .toList();

    final transactionDateString = json['transactionDate'] as String?;
    DateTime transactionDate;
    if (transactionDateString != null) {
      try {
        transactionDate = DateFormat("E, d MMM yyyy").parse(transactionDateString);
      } catch (e) {
        transactionDate = DateTime.parse('1970-01-01');
      }
    } else {
      transactionDate = DateTime.parse('1970-01-01');
    }

    return PricePaidModel(
      transactionId: json['transactionId'] as String? ?? '',
      amount: json['pricePaid'] as int? ?? 0,
      transactionDate: transactionDate,
      propertyType: _getPropertyType(json['propertyType']?['_about'] as String?),
      fullAddress: addressParts.join(', '),
      // 3. Pass the parsed paon value to the constructor
      paon: paon,
    );
  }
}
