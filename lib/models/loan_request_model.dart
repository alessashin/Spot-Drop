import 'package:cloud_firestore/cloud_firestore.dart';

enum LoanStatus { pending, active, returned, rejected }

class LoanRequestModel {
  final String id;
  final String itemId;
  final String itemTitle;
  final String itemImageUrl;
  final String borrowerId;
  final String ownerId;
  final DateTime startDate;
  final DateTime endDate;
  final LoanStatus status;
  final List<String> pickupConditionPhotos;
  final List<String> returnConditionPhotos;
  final DateTime requestedAt;

  LoanRequestModel({
    required this.id,
    required this.itemId,
    required this.itemTitle,
    required this.itemImageUrl,
    required this.borrowerId,
    required this.ownerId,
    required this.startDate,
    required this.endDate,
    this.status = LoanStatus.pending,
    this.pickupConditionPhotos = const [],
    this.returnConditionPhotos = const [],
    required this.requestedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemId': itemId,
      'itemTitle': itemTitle,
      'itemImageUrl': itemImageUrl,
      'borrowerId': borrowerId,
      'ownerId': ownerId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'status': status.name,
      'pickupConditionPhotos': pickupConditionPhotos,
      'returnConditionPhotos': returnConditionPhotos,
      'requestedAt': Timestamp.fromDate(requestedAt),
    };
  }

  factory LoanRequestModel.fromMap(Map<String, dynamic> map, String docId) {
    return LoanRequestModel(
      id: docId,
      itemId: map['itemId'] ?? '',
      itemTitle: map['itemTitle'] ?? '',
      itemImageUrl: map['itemImageUrl'] ?? '',
      borrowerId: map['borrowerId'] ?? '',
      ownerId: map['ownerId'] ?? '',
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      status: LoanStatus.values.firstWhere(
            (e) => e.name == map['status'],
        orElse: () => LoanStatus.pending,
      ),
      pickupConditionPhotos: List<String>.from(map['pickupConditionPhotos'] ?? []),
      returnConditionPhotos: List<String>.from(map['returnConditionPhotos'] ?? []),
      requestedAt: (map['requestedAt'] as Timestamp).toDate(),
    );
  }
}