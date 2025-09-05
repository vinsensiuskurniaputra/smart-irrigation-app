import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final Rx<ConnectivityResult> connectivityStatus = ConnectivityResult.none.obs;
  final RxBool isConnected = false.obs;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  Future<ConnectivityService> init() async {
    // Get initial connectivity status
    connectivityStatus.value = await _connectivity.checkConnectivity();
    _updateConnectionStatus(connectivityStatus.value);

    // Subscribe to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    
    return this;
  }

  void _updateConnectionStatus(ConnectivityResult connectivityResult) {
    connectivityStatus.value = connectivityResult;
    isConnected.value = (connectivityResult == ConnectivityResult.wifi || 
                         connectivityResult == ConnectivityResult.mobile ||
                         connectivityResult == ConnectivityResult.ethernet);
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }

  // Method to check current connectivity
  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
    return isConnected.value;
  }
}
