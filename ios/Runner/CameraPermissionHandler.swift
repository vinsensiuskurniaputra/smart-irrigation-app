import Flutter
import UIKit
import AVFoundation

class CameraPermissionHandler: NSObject {
    static func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            print("Camera permission granted: \(granted)")
        }
    }
}
