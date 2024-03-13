//
//  CustomError.swift
//  SimpleCameraCapture
//
//  Created by Martin Šimar on 13.03.2024.
//

import Foundation

enum CustomError: Error, LocalizedError {
    case cameraAccessDenied
    case setupCameraFailed

    var errorDescription: String? {
        switch self {
        case .cameraAccessDenied:
            return "Please provide access to camera for capture"
        case .setupCameraFailed:
            return "Camera setup failed, please try again."
        }
    }
}
