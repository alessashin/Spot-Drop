import 'package:cloud_firestore/cloud_firestore.dart';

enum ItemType { borrowable, giveaway }

class ItemModel {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final String category;
  final ItemType type;
  final List<String> imageUrls;
  final double latitude;
  final double longitude;
  final bool isAvailable;
  final DateTime createdAt;

  ItemModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.imageUrls,
    required this.latitude,
    required this.longitude,
    this.isAvailable = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'category': category,
      'type': type.name,
      'imageUrls': imageUrls,
      'latitude': latitude,
      'longitude': longitude,
      'isAvailable': isAvailable,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ItemModel.fromMap(Map<String, dynamic> map, String docId) {
    return ItemModel(
      id: docId,
      ownerId: map['ownerId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'General',
      type: ItemType.values.firstWhere(
            (e) => e.name == map['type'],
        orElse: () => ItemType.borrowable,
      ),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      isAvailable: map['isAvailable'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}