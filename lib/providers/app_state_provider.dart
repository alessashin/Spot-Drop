import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/item_model.dart';
import '../models/loan_request_model.dart';
import '../services/firebase_service.dart';

class AppStateProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  LatLng? _userLocation;
  final String _currentUserId = "user_demo_123"; // Simulated authenticated user ID

  LatLng? get userLocation => _userLocation;
  String get currentUserId => _currentUserId;

  Stream<List<ItemModel>> get itemsStream => _firebaseService.streamItems();

  Stream<List<LoanRequestModel>> get requestsStream =>
      _firebaseService.streamLoanRequests(_currentUserId);

  void setLocation(double lat, double lng) {
    _userLocation = LatLng(lat, lng);
    notifyListeners();
  }
}