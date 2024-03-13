//
//  ContentView.swift
//  SimpleCameraCapture
//
//  Created by Martin Šimar on 27.02.2024.
//

import SwiftUI

struct ContentView: View {
    // Usually this variables will be in ViewModel, but for test project is fine ;)
    @State private var showCameraSheet = false
    @State private var image: UIImage?

    var body: some View {
        VStack {
            if let safeImage = image {
                Image(uiImage: safeImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            }
            Button("Show camera", action: {
                showCameraSheet = true
            })
        }
        .padding()
        .fullScreenCover(isPresented: $showCameraSheet, content: {
            CameraView(image: $image)
        })
    }
}

#Preview {
    ContentView()
}
