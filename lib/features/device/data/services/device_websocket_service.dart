import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:smart_irrigation_app/core/utils/local_storage_service.dart';
import 'package:smart_irrigation_app/core/constants/API/api_urls.dart';
import 'package:smart_irrigation_app/features/device/data/models/live_sensor_model.dart';

abstract class DeviceWebSocketService {
  Stream<LiveDataModel> connectToDeviceLive(int deviceId);
  void disconnect();
}

class DeviceWebSocketServiceImpl implements DeviceWebSocketService {
  WebSocketChannel? _channel;
  StreamController<LiveDataModel>? _controller;
  StreamSubscription? _subscription;
  bool _isConnecting = false;
  final LocalStorageService _localStorage;

  DeviceWebSocketServiceImpl(this._localStorage);

  @override
  Stream<LiveDataModel> connectToDeviceLive(int deviceId) {
    // Prevent multiple simultaneous connections
    if (_isConnecting) {
      print('⚠️ WebSocket connection already in progress');
      return _controller?.stream ?? const Stream.empty();
    }
    
    disconnect(); // Close any existing connection
    
    _controller = StreamController<LiveDataModel>();
    
    _connectWithAuth(deviceId);
    
    return _controller!.stream;
  }

  Future<void> _connectWithAuth(int deviceId) async {
    if (_isConnecting) return;
    
    _isConnecting = true;
    
    try {
      final token = await _localStorage.getToken();
      final uri = Uri.parse(ApiUrls.deviceLive(deviceId));
      
      print('=== WebSocket Connection Debug ===');
      print('Attempting to connect to: ${uri.toString()}');
      print('Device ID: $deviceId');
      print('Token available: ${token != null}');
      if (token != null) {
        print('Token length: ${token.length}');
      }
      
      // Add authorization header to WebSocket
      final headers = <String, String>{};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
        print('Adding Authorization header');
      }
      
      print('Headers: $headers');
      print('Connecting...');
      
      // Use IOWebSocketChannel for proper header support
      final socket = await WebSocket.connect(
        uri.toString(),
        headers: headers,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('WebSocket connection timeout after 10 seconds');
          return throw TimeoutException('WebSocket connection timeout', const Duration(seconds: 10));
        },
      );
      
      print('✅ WebSocket connected successfully!');
      
      _channel = IOWebSocketChannel(socket);
      
      _subscription = _channel!.stream.listen(
        (data) {
          try {
            // Check if controller is still active before processing data
            if (_controller?.isClosed == false) {
              print('📨 Received WebSocket data: $data');
              final jsonData = json.decode(data as String) as Map<String, dynamic>;
              final liveData = LiveDataModel.fromJson(jsonData);
              print('📊 Parsed ${liveData.sensors.length} sensors');
              _controller?.add(liveData);
            } else {
              print('🚫 Ignoring WebSocket data - controller is closed');
            }
          } catch (e) {
            print('❌ Failed to parse WebSocket data: $e');
            // Only add error if controller is still active
            if (_controller?.isClosed == false) {
              _controller?.addError('Failed to parse WebSocket data: $e');
            }
          }
        },
        onError: (error) {
          print('❌ WebSocket stream error: $error');
          // Only add error if controller is still active
          if (_controller?.isClosed == false) {
            _controller?.addError('WebSocket error: $error');
          }
        },
        onDone: () {
          print('🔌 WebSocket connection closed');
          // Only close if controller is still active
          if (_controller?.isClosed == false) {
            _controller?.close();
          }
        },
      );
      
      _isConnecting = false;
      
    } catch (e) {
      _isConnecting = false;
      print('❌ Failed to connect to WebSocket: $e');
      if (e is SocketException) {
        print('Socket Exception Details:');
        print('  - Address: ${e.address}');
        print('  - Port: ${e.port}');
        print('  - OS Error: ${e.osError}');
        print('  - Message: ${e.message}');
      }
      
      // Only add error if controller is still active
      if (_controller?.isClosed == false) {
        _controller?.addError('Failed to connect to WebSocket: $e');
      }
    }
  }

  @override
  void disconnect() {
    print('🔌 Disconnecting WebSocket...');
    
    _isConnecting = false;
    
    // Cancel subscription first to stop listening to new data
    _subscription?.cancel();
    _subscription = null;
    
    // Close the WebSocket channel
    try {
      _channel?.sink.close();
    } catch (e) {
      print('Warning: Error closing WebSocket sink: $e');
    }
    _channel = null;
    
    // Close the stream controller
    try {
      if (_controller?.isClosed == false) {
        _controller?.close();
      }
    } catch (e) {
      print('Warning: Error closing stream controller: $e');
    }
    _controller = null;
    
    print('✅ WebSocket disconnected');
  }
}
