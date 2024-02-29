//
//  CameraView.swift
//  SimpleCameraCapture
//
//  Created by Martin Šimar on 27.02.2024.
//

import SwiftUI

struct CameraView: View {
    @StateObject var vm = CameraViewModel()
    @Environment(\.openURL) var openURL
    @Environment(\.dismiss) var dismiss
    
    @Binding var image: UIImage?
    
    var body: some View {
        GeometryReader{geo in
            ZStack{
                Group{
                    if vm.photoData == nil{
                        CameraViewRepresentable(frame: geo.frame(in: .global), cameraVM: vm)
                    }else{
                        if let photo = vm.showingPhoto{
                            Image(uiImage: photo)
                                .resizable()
                                .scaledToFit()
                        }
                    }
                }.frame(width: geo.size.width, height: geo.size.height)
                    
                VStack{
                    Spacer()
                    //Buttons
                    HStack{
                        if case .notStarted = vm.photoCaptureState {
                            Button("Close") {
                                dismiss()
                            }
                            Spacer()
                            Spacer()
                            Button(action: {
                                vm.takePhoto()
                            }) {
                                Image(systemName: "camera.circle.fill")
                                    .resizable()
                                    .frame(width: 70, height: 70)
                            }
                            Spacer()
                            Spacer()
                            Spacer()
                        }else{
                            Button("Retake") {
                                vm.retakePhoto()
                            }
                            Spacer()
                            Button("Save") {
                                if let data = vm.photoData{
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
        .ignoresSafeArea()
        
        .alert(vm.errorMessage, isPresented: $vm.showError) {
            //Showing settings button, if permission is denied
            if vm.cameraPermission == .denied{
                Button("Settings") {
                    let settingsString = UIApplication.openSettingsURLString
                    if let settingsURL = URL(string: settingsString){
                        // open apps settings
                        openURL(settingsURL)
                    }
                }
            }
            Button("cancel", role: .cancel) { dismiss() }
        }
        .onAppear(perform: vm.checkCameraPermision)
        .onDisappear(perform: vm.stopSession)
    }
}

#Preview {
    CameraView(image: .constant(nil))
}
