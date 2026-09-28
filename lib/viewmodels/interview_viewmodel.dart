import 'package:flutter/foundation.dart';

class InterviewViewmodel extends ChangeNotifier{
  String? _selectedRole;
  bool _isConnecting = false;

  String? get selectedRole => _selectedRole;
  bool get isConnecting => _isConnecting;

  void selectRole(String role) {
    _selectedRole = role;
    notifyListeners();
  }

  Future<void> startInterviewSession() async {
    _isConnecting = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _isConnecting = false;
    notifyListeners();
  }
}