//
//  CameraViewModel.swift
//  SimpleCameraCapture
//
//  Created by Martin Šimar on 28.02.2024.
//

import Foundation
import UIKit
import Combine

final class CameraViewModel: ObservableObject {
    private var cancellables = Swift.Set<AnyCancellable>()

    @Published var cameraPermission: CameraPermission = .idle
    @Published var photoCaptureState: PhotoCaptureState = .notStarted

    @Published var showingPhoto: UIImage?
    @Published var recievedPhotoData: Data?
    // Error
    @Published var errorMessage: CustomError?
    @Published var showError: Bool = false

    init() {
        print("init")
        addSubscribers()
    }

    func startCameraSession() {
        do {
            try AVCaptureManager.shared.checkCameraPermision()
        } catch {
            self.errorMessage = error as? CustomError
            self.showError.toggle()
        }
    }

    func endSession() {
        recievedPhotoData = nil
        showingPhoto = nil
        cameraPermission = .idle
        photoCaptureState = .notStarted
    }

    func takePhoto() {
        AVCaptureManager.shared.takePhoto()
    }

    func retakePhoto() {
        AVCaptureManager.shared.retakePhoto()
    }

    // Combine subscription
    private func addSubscribers() {
        AVCaptureManager.shared.$cameraPermission
            .sink { [weak self] cameraPermision in
                self?.cameraPermission = cameraPermision
            }
            .store(in: &cancellables)

        AVCaptureManager.shared.$photoCaptureState
            .sink { [weak self] photoState in
                self?.photoCaptureState = photoState
            }
            .store(in: &cancellables)

        AVCaptureManager.shared.$outputData
            .sink { [weak self] recievedData in
                self?.recievedPhotoData = recievedData
                if let data = recievedData {
                    self?.showingPhoto = UIImage(data: data)
                } else {
                    self?.showingPhoto = nil
                }
            }
            .store(in: &cancellables)
    }
}
