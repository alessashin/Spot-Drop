import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/item_model.dart';
import '../models/loan_request_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Stream active catalog items
  Stream<List<ItemModel>> streamItems() {
    return _db.collection('items').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ItemModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Add new item with image uploads
  Future<void> addItem(ItemModel item, List<dynamic> imageFiles) async {
    List<String> uploadedUrls = [];

    for (int i = 0; i < imageFiles.length; i++) {
      String path = 'items/${item.id}_img_$i.jpg';
      Reference ref = _storage.ref().child(path);

      UploadTask task;
      if (kIsWeb) {
        task = ref.putData(imageFiles[i] as Uint8List);
      } else {
        task = ref.putFile(imageFiles[i] as File);
      }

      TaskSnapshot snapshot = await task;
      String url = await snapshot.ref.getDownloadURL();
      uploadedUrls.add(url);
    }

    ItemModel finalItem = ItemModel(
      id: item.id,
      ownerId: item.ownerId,
      title: item.title,
      description: item.description,
      category: item.category,
      type: item.type,
      imageUrls: uploadedUrls,
      latitude: item.latitude,
      longitude: item.longitude,
      isAvailable: true,
      createdAt: DateTime.now(),
    );

    await _db.collection('items').doc(item.id).set(finalItem.toMap());
  }

  // Create a borrowing request
  Future<void> createLoanRequest(LoanRequestModel request) async {
    await _db.collection('loan_requests').doc(request.id).set(request.toMap());
  }

  // Stream user's requests (as borrower or owner)
  Stream<List<LoanRequestModel>> streamLoanRequests(String userId) {
    return _db
        .collection('loan_requests')
        .where('borrowerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => LoanRequestModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }


  Future<void> updateLoanStatus(String requestId, LoanStatus newStatus) async {
    await _db.collection('loan_requests').doc(requestId).update({
      'status': newStatus.name,
    });
  }
}