//
//  CameraView.swift
//  SimpleCameraCapture
//
//  Created by Martin Šimar on 27.02.2024.
//
import UIKit
import AVFoundation
import SwiftUI
import AVKit

struct CameraViewRepresentable: UIViewRepresentable {
    let frame: CGRect
    @ObservedObject var cameraVM: CameraViewModel

    func makeUIView(context: Context) -> UIView {
        let view = UIViewType(frame: frame)
        view.backgroundColor = .clear

        AVCaptureManager.shared.preview.session = AVCaptureManager.shared.session
        AVCaptureManager.shared.preview.frame = frame
        AVCaptureManager.shared.preview.videoGravity = .resizeAspectFill
        let orientation = UIDevice.current.orientation
        AVCaptureManager.shared.preview.connection?.videoRotationAngle =  orientation.videoRotationAngle
        AVCaptureManager.shared.preview.masksToBounds = true

        view.layer.addSublayer(AVCaptureManager.shared.preview)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        AVCaptureManager.shared.preview.frame = frame
        AVCaptureManager.shared.preview.connection?.videoRotationAngle = UIDevice.current.orientation.videoRotationAngle
    }
}
