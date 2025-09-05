import Flutter
import UIKit
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Request camera permission on app start
    CameraPermissionHandler.requestPermission()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
