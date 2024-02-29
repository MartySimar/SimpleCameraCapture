//
//  CameraViewModel.swift
//  SimpleCameraCapture
//
//  Created by Martin Šimar on 28.02.2024.
//

import Foundation
import AVFoundation
import UIKit


final class CameraViewModel: NSObject, ObservableObject{
    
    @Published var cameraPermission: CameraPermission = .idle
    @Published var session: AVCaptureSession = .init()
    @Published var preview = AVCaptureVideoPreviewLayer()
    //output
    @Published var cameraOutput = AVCapturePhotoOutput()
    @Published var photoCaptureState: PhotoCaptureState = .notStarted
    @Published var showingPhoto: UIImage?
    //Error
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    
    var photoData: Data? {
        if case .finished(let data) = photoCaptureState {
            return data
        }
        return nil
    }
    
    //checking camera permision
    func checkCameraPermision() {
        Task{
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                await MainActor.run{
                    cameraPermission = .approved
                }
                await setupCamera()
            case.notDetermined:
                // requesting camera access
                if await AVCaptureDevice.requestAccess(for: .video) {
                    //Access granted
                    await MainActor.run{
                        cameraPermission = .approved
                    }
                    await setupCamera()
                }else{
                    //access denied
                    await MainActor.run{
                        cameraPermission = .denied
                    }
                    presentError("Please provide access to camera for capture")
                }
            case .denied, .restricted:
                await MainActor.run{
                    cameraPermission = .denied
                }
                presentError("Please provide access to camera for capture")
            default: break
            }
        }
    }
    
    //Setting up camera
    func setupCamera() async{
        do{
            self.session.beginConfiguration()
            guard let backCamera = AVCaptureDevice.default(for: .video) else {
                        print("Unable to access back camera!")
                        return
                    }
            
            let input = try AVCaptureDeviceInput(device: backCamera)
            
            if session.canAddInput(input) {
                session.addInput(input)
                if session.canAddOutput(cameraOutput) {
                    session.addOutput(cameraOutput)
                    self.session.commitConfiguration()
                    Task(priority: .background){
                        self.session.startRunning()
                    }
                }
            }
        }catch{
            presentError(error.localizedDescription)
        }
    }
    
    func stopSession(){
        Task{
            if session.isRunning{
                session.stopRunning()
            }
        }
    }
    
    func takePhoto(){
        guard case .notStarted = photoCaptureState else { return }
        cameraOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        self.photoCaptureState = .processing
    }
    
    func retakePhoto(){
        Task(priority: .background){
            self.session.startRunning()
            await MainActor.run {
                self.photoCaptureState = .notStarted
            }
        }
    }
    
    //presenting error
    func presentError(_ message: String){
        errorMessage = message
        showError.toggle()
    }
}

extension CameraViewModel: AVCapturePhotoCaptureDelegate{
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error {
            presentError("There was a error processing photo, try again.")
            print(error.localizedDescription)
        }
        
        guard let rawImageData = photo.fileDataRepresentation() else { return }
        
        //Image orientation
        guard let provider = CGDataProvider(data: rawImageData as CFData) else { return }
        guard let cgImage = CGImage(jpegDataProviderSource: provider, decode: nil, shouldInterpolate: true, intent: .defaultIntent) else { return }
        
        Task(priority: .background){
            self.session.stopRunning()
            await MainActor.run {
                let image = UIImage(cgImage: cgImage, scale: 1, orientation: UIDevice.current.orientation.uiImageOrientation)
                let finalData = image.jpegData(compressionQuality: 1)
                self.photoCaptureState = .finished(finalData)
                self.showingPhoto = image
            }
        }
    }
}
