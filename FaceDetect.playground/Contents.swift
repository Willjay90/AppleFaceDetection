// Swift 4, Xcode 9.1 (9B46)

import Vision
import UIKit

extension UIImage {
    var ciImage: CIImage? {
        guard let data = UIImagePNGRepresentation(self) else { return nil }
        return CIImage(data: data)
    }
    
    // Face Detection with CIDetector
    var faces: [UIImage] {
        guard let ciImage = ciImage else { return [] }
        return (CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])?
            .features(in: ciImage) as? [CIFaceFeature])?
            .map {
                let ciimage = ciImage.cropped(to: $0.bounds)
                return UIImage(ciImage: ciimage)
            }  ?? []
    }
    
    // Face Detection with Vision Framework
    var faces_Vision: [UIImage] {
        guard let ciImage = ciImage else { return [] }

        let faceDetectionRequest = VNDetectFaceRectanglesRequest()
        try! VNImageRequestHandler(ciImage: ciImage).perform([faceDetectionRequest])
        
        guard let results = faceDetectionRequest.results as? [VNFaceObservation] else { return [] }
        
        return results.map {
            let translate = CGAffineTransform.identity.scaledBy(x: size.width, y: size.height)
            let bounds = $0.boundingBox.applying(translate)
            let ciimage = ciImage.cropped(to: bounds)
            return UIImage(ciImage: ciimage)
        }
    }
    
    
}

// Get an image from URL
let url = URL(string: "https://i.imgur.com/EoB6uEI.jpg")!
let data = try! Data(contentsOf: url)
if let image = UIImage(data: data) {
    // CIDetector
    let faces = image.faces
    print(faces.count)
    
    // Vision
    let faces_v = image.faces_Vision
    print(faces_v.count)

}





