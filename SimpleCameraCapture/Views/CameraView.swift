//
//  CameraView.swift
//  SimpleCameraCapture
//
//  Created by Martin Šimar on 27.02.2024.
//

import SwiftUI

struct CameraView: View {
    @StateObject var viewModel = CameraViewModel()
    @Environment(\.openURL) var openURL
    @Environment(\.dismiss) var dismiss

    @Binding var image: UIImage?

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Camera(geo: geo, viewModel: viewModel)
                buttonPanel
            }
        }
        .ignoresSafeArea()
        .alert(isPresented: $viewModel.showError, error: viewModel.errorMessage) {
            // Showing settings button, if permission is denied
            if viewModel.cameraPermission == .denied {
                Button("Settings") {
                    let settingsString = UIApplication.openSettingsURLString
                    if let settingsURL = URL(string: settingsString) {
                        // open apps settings
                        openURL(settingsURL)
                    }
                }
            }
            Button("cancel", role: .cancel) { dismiss() }
        }
        .onAppear(perform: viewModel.startCameraSession)
    }
}

extension CameraView {
    private var buttonPanel: some View {
        VStack {
            Spacer()
            // Buttons
            HStack {
                if case .notStarted = viewModel.photoCaptureState {
                    ZStack {
                        HStack {
                            Button("Close") {
                                viewModel.endSession()
                                dismiss()
                            }
                            Spacer()
                        }
                        Button {
                            viewModel.takePhoto()
                        } label: {
                            Image(systemName: "camera.circle.fill")
                                .resizable()
                                .frame(width: 70, height: 70)
                        }
                    }
                } else {
                    Button("Retake") {
                        viewModel.retakePhoto()
                    }
                    Spacer()
                    Button("Save") {
                        if let data = viewModel.recievedPhotoData {
                            image = UIImage(data: data)
                            dismiss()
                        }
                    }
                }
            }.padding()
                .padding(.bottom, 30)
                .frame(maxWidth: .infinity, alignment: .center)
                .background {
                    Rectangle()
                        .foregroundStyle(.ultraThinMaterial)
                }
                .ignoresSafeArea()
        }
    }
}

#Preview {
    CameraView(image: .constant(nil))
}
