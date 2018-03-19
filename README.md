# Face Detection with Vision Framework
![ios11+](https://img.shields.io/badge/ios-11%2B-blue.svg)
![swift4+](https://img.shields.io/badge/swift-4%2B-orange.svg)


Previously, in iOS 10, to detect faces in a picture, you can use [CIDetector](https://developer.apple.com/reference/coreimage/cidetector) (Apple)
or [Mobile Vision](https://developers.google.com/vision/face-detection-concepts) (Google)

In iOS11, Apple introduces [CoreML](https://developer.apple.com/documentation/coreml). With the **[Vision Framework](https://developer.apple.com/documentation/vision)**, it's much easier to detect faces in real time 😃

Try it out with real time face detection on your iPhone! 📱

<img src="https://github.com/Weijay/AppleFaceDetection/blob/master/resources/VNDetectFaceRectanglesRequest.png" width="250" height="400"/> <img src="https://github.com/Weijay/AppleFaceDetection/blob/master/resources/VNDetectFaceLandmarksRequest.png" width="250" height="400"/>  <img src="https://github.com/Weijay/AppleFaceDetection/blob/master/resources/faceRecognition.gif" />

You can find out the differences between `CIDetector` and `Vison Framework` down below.

[Moving From Voila-Jones to Deep Learning](https://machinelearning.apple.com/2017/11/16/face-detection.html)


---

## Details

Specify the `VNRequest` for face recognition, either `VNDetectFaceRectanglesRequest` or `VNDetectFaceLandmarksRequest`.

```swift
private var requests = [VNRequest]() // you can do mutiple requests at the same time

var faceDetectionRequest: VNRequest!
@IBAction func UpdateDetectionType(_ sender: UISegmentedControl) {
    // use segmentedControl to switch over VNRequest
    faceDetectionRequest = sender.selectedSegmentIndex == 0 ? VNDetectFaceRectanglesRequest(completionHandler: handleFaces) : VNDetectFaceLandmarksRequest(completionHandler: handleFaceLandmarks) 
}

```

Perform the requests every single frame. The image comes from camera via `captureOutput(_:didOutput:from:)`, see [AVCaptureVideoDataOutputSampleBufferDelegate](https://developer.apple.com/documentation/avfoundation/avcapturevideodataoutputsamplebufferdelegate/1385775-captureoutput) 

```swift
func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
        let exifOrientation = CGImagePropertyOrientation(rawValue: exifOrientationFromDeviceOrientation()) else { return }
    var requestOptions: [VNImageOption : Any] = [:]

    if let cameraIntrinsicData = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
      requestOptions = [.cameraIntrinsics : cameraIntrinsicData]
    }
    
    // perform image request for face recognition
    let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: requestOptions)

    do {
      try imageRequestHandler.perform(self.requests)
    }

    catch {
      print(error)
    }

}
```

Handle the return of your request, `VNRequestCompletionHandler`.  
- `handleFaces` for `VNDetectFaceRectanglesRequest`
- `handleFaceLandmarks` for `VNDetectFaceLandmarksRequest`

then you will get the result from the request, which are `VNFaceObservation`s. That's all you got from the **Vision API**

```swift
func handleFaces(request: VNRequest, error: Error?) {
    DispatchQueue.main.async {
        //perform all the UI updates on the main queue
        guard let results = request.results as? [VNFaceObservation] else { return }
        print("face count = \(results.count) ")
        self.previewView.removeMask()

        for face in results {
            self.previewView.drawFaceboundingBox(face: face)
        }
    }
}
    
func handleFaceLandmarks(request: VNRequest, error: Error?) {
    DispatchQueue.main.async {
        //perform all the UI updates on the main queue
        guard let results = request.results as? [VNFaceObservation] else { return }
        self.previewView.removeMask()
        for face in results {
            self.previewView.drawFaceWithLandmarks(face: face)
        }
    }
}
```

Lastly, **DRAW** corresponding location on the screen!
<Hint: [UIBezierPath](https://developer.apple.com/documentation/uikit/uibezierpath) to draw line for landmarks>

```swift
func drawFaceboundingBox(face : VNFaceObservation) {
    // The coordinates are normalized to the dimensions of the processed image, with the origin at the image's lower-left corner.

    let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -frame.height)

    let scale = CGAffineTransform.identity.scaledBy(x: frame.width, y: frame.height)

    let facebounds = face.boundingBox.applying(scale).applying(transform)

    _ = createLayer(in: facebounds)

}

// Create a new layer drawing the bounding box
private func createLayer(in rect: CGRect) -> CAShapeLayer {

    let mask = CAShapeLayer()
    mask.frame = rect
    mask.cornerRadius = 10
    mask.opacity = 0.75
    mask.borderColor = UIColor.yellow.cgColor
    mask.borderWidth = 2.0

    maskLayer.append(mask)
    layer.insertSublayer(mask, at: 1)

    return mask
}

```
