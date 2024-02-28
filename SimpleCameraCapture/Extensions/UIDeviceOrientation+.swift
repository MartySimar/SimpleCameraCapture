//
//  UIDeviceOrientation+.swift
//  SimpleCameraCapture
//
//  Created by Martin Šimar on 28.02.2024.
//

import Foundation
import UIKit

extension UIDeviceOrientation{
    var videoRotationAngle: CGFloat{
        switch self {
        case .portrait:
            90
        case .landscapeLeft:
            0
        case .landscapeRight:
            180
        case .portraitUpsideDown:
            270
        default:
            90
        }
    }
    
    var uiImageOrientation: UIImage.Orientation {
        switch self {
        case .landscapeLeft:
                .up
        case .portrait:
                .right
        case.landscapeRight:
                .down
        case .portraitUpsideDown:
                .left
        default:
                .right
        }
    }
}
