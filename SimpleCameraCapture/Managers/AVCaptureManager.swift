//
//  AVCaptureManager.swift
//  SimpleCameraCapture
//
//  Created by Martin Šimar on 13.03.2024.
//

import Foundation
import AVFoundation
import UIKit

final class AVCaptureManager: NSObject, ObservableObject {
    // Singleton instance
    static let shared = AVCaptureManager()

    @Published var cameraPermission: CameraPermission = .idle
    @Published var session = AVCaptureSession()
    @Published var preview = AVCaptureVideoPreviewLayer()
    // output
    private var cameraOutput = AVCapturePhotoOutput()
    private var isSessionConfigured = false
    @Published var photoCaptureState: PhotoCaptureState = .notStarted
    @Published var outputData: Data?

    // checking camera permision
    func checkCameraPermision() throws {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraPermission = .approved
            try setupCamera()
        case.notDetermined:
            // requesting camera access
            Task {
                if await AVCaptureDevice.requestAccess(for: .video) {
                    // Access granted
                    try await MainActor.run {
                        cameraPermission = .approved
                        try setupCamera()
                    }
                } else {
                    // access denied
                    try await MainActor.run {
                        cameraPermission = .denied
                        throw CustomError.cameraAccessDenied
                    }
                }
            }
        case .denied, .restricted:
            cameraPermission = .denied
            throw CustomError.cameraAccessDenied
        default: break
        }
    }

    // Setting up camera
    func setupCamera() throws {
        self.photoCaptureState = .notStarted
        self.outputData = nil

        if !isSessionConfigured {
            self.session.beginConfiguration()
            guard let backCamera = AVCaptureDevice.default(for: .video) else { throw CustomError.setupCameraFailed }
            guard let input = try? AVCaptureDeviceInput(device: backCamera) else { throw CustomError.setupCameraFailed }

            if session.canAddInput(input) {
                session.addInput(input)
                if session.canAddOutput(cameraOutput) {
                    session.addOutput(cameraOutput)
                    self.session.commitConfiguration()
                    self.isSessionConfigured = true
                    self.startSession()
                }
            }
        } else {
            self.startSession()
        }
    }

    func startSession() {
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
        }
    }

    func stopSession() {
        if session.isRunning {
            DispatchQueue.global(qos: .background).async {
                self.session.stopRunning()
            }
        }
    }

    func takePhoto() {
        guard case .notStarted = photoCaptureState else { return }
        cameraOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        self.photoCaptureState = .processing
    }

    func retakePhoto() {
        self.photoCaptureState = .notStarted
        self.outputData = nil
        self.startSession()
    }
}

extension AVCaptureManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error {
            print(error.localizedDescription)
        }

        guard let rawImageData = photo.fileDataRepresentation() else { return }

        // Image orientation
        guard let provider = CGDataProvider(data: rawImageData as CFData) else { return }
        guard let cgImage = CGImage(
            jpegDataProviderSource: provider,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        ) else { return }

        let image = UIImage(
            cgImage: cgImage,
            scale: 1,
            orientation: UIDevice.current.orientation.uiImageOrientation
        )
        let finalData = image.jpegData(compressionQuality: 1)
        self.photoCaptureState = .finished
        self.stopSession()
        self.outputData = finalData
    }
}
