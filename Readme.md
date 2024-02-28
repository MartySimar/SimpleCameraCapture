#  Simple Camera

This project is SwiftUI simple camera for taking photos and pass them to other parts of project.

## Description

Using AVFoundation library, this project creates `AVCaptureSession` with `AVCaptureVideoPreviewLayer` that is handled by UIViewRepresentable. Camera view frame is set by `Geometry reader` to fill whole screen. After taking photo, the captured image is shown instead of camera view, user then can retake or save photo. Save photo is passed by `@Binding` variable to its parent view. 
This proect also follows `MVVM` architecture.

## Techstack used

- SwiftUI
- Swift
- AVFoundation
- MVVM
