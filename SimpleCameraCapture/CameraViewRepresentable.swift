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

struct CameraViewRepresentable: UIViewRepresentable{
    let frame: CGRect
    @ObservedObject var cameraVM: CameraViewModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIViewType(frame: frame)
        view.backgroundColor = .clear
        
        cameraVM.preview.session = cameraVM.session
        cameraVM.preview.frame = frame
        cameraVM.preview.videoGravity = .resizeAspectFill
        let orientation = UIDevice.current.orientation
        cameraVM.preview.connection?.videoRotationAngle =  orientation.videoRotationAngle
        cameraVM.preview.masksToBounds = true
        view.layer.addSublayer(cameraVM.preview)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        cameraVM.preview.frame = frame
        cameraVM.preview.connection?.videoRotationAngle = UIDevice.current.orientation.videoRotationAngle
    }
}
