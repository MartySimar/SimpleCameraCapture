//
//  Camera.swift
//  SimpleCameraCapture
//
//  Created by Martin Šimar on 13.03.2024.
//

import Foundation
import SwiftUI

struct Camera: View {
    let geo: GeometryProxy
    @ObservedObject var viewModel: CameraViewModel
    var body: some View {
        Group {
            if viewModel.recievedPhotoData == nil {
                CameraViewRepresentable(frame: geo.frame(in: .global), cameraVM: viewModel)
            } else {
                if let photo = viewModel.showingPhoto {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFit()
                }
            }
        }.frame(width: geo.size.width, height: geo.size.height)
    }
}
