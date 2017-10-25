//
//  PreviewView.swift
//  VisionDetection
//
//  Created by Wei Chieh Tseng on 09/06/2017.
//  Copyright © 2017 Willjay. All rights reserved.
//

import UIKit
import Vision
import AVFoundation

class PreviewView: UIView {
    
    private var maskLayer = [CAShapeLayer]()
    
    
    // MARK: AV capture properties
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    var session: AVCaptureSession? {
        get {
            return videoPreviewLayer.session
        }
        
        set {
            videoPreviewLayer.session = newValue
        }
    }
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    func drawLayer(in rect: CGRect) {
        
        let mask = CAShapeLayer()
        mask.frame = rect
        
        mask.backgroundColor = UIColor.yellow.cgColor
        mask.cornerRadius = 10
        mask.opacity = 0.3
        mask.borderColor = UIColor.yellow.cgColor
        mask.borderWidth = 2.0
        
        maskLayer.append(mask)
        layer.insertSublayer(mask, at: 1)
    }
    
    func drawFaceWithLandmarks(face: VNFaceObservation) {
        
        let translate = CGAffineTransform.identity.scaledBy(x: layer.frame.width, y: layer.frame.height)
        let transform = CGAffineTransform(scaleX: -1, y: -1).translatedBy(x: -layer.frame.width, y: -layer.frame.height)
        let faceRect = face.boundingBox.applying(translate).applying(transform)
        
        // Draw the bounding rect
        let faceLayer = self.createLayer(in: faceRect)
        maskLayer.append(faceLayer)
        layer.insertSublayer(faceLayer, at: 1)
        
        // Draw the landmarks
        self.drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.nose)!, isClosed:false)
        self.drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.noseCrest)!, isClosed:false)
        self.drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.medianLine)!, isClosed:false)
        self.drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.leftEye)!)
        self.drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.leftPupil)!)
        self.drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.leftEyebrow)!, isClosed:false)
        self.drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.rightEye)!)
        self.drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.rightPupil)!)
        self.drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.rightEye)!)
        self.drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.rightEyebrow)!, isClosed:false)
        self.drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.innerLips)!)
        self.drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.outerLips)!)
        self.drawLandmarks(on: faceLayer, faceLandmarkRegion: (face.landmarks?.faceContour)!, isClosed: false)
    }
    
    func createLayer(in rect: CGRect) -> CAShapeLayer{
        
        let mask = CAShapeLayer()
        mask.frame = rect
        mask.cornerRadius = 10
        mask.opacity = 0.75
        mask.borderColor = UIColor.yellow.cgColor
        mask.borderWidth = 2.0
        
        return mask
    }
    
    func drawLandmarks(on targetLayer:CALayer, faceLandmarkRegion: VNFaceLandmarkRegion2D, isClosed: Bool = true) {
        let rect: CGRect = targetLayer.frame
        var points: [CGPoint] = []
        for i in 0..<faceLandmarkRegion.pointCount {
            let point = faceLandmarkRegion.normalizedPoints[i]
            let p = CGPoint(x: CGFloat(point.x), y: CGFloat(point.y))
            points.append(p)
        }
        
        let landmarkLayer = self.drawPointsOnLayer(rect: rect, landmarkPoints: points, isClosed: isClosed)
        
        // Change scale, coordinate systems, and mirroring
        landmarkLayer.transform = CATransform3DMakeAffineTransform(
            CGAffineTransform.identity
                .translatedBy(x: rect.width, y: 0)
                .scaledBy(x: -1, y: 1)
                .scaledBy(x: rect.width, y:rect.height)
                .scaledBy(x: 1, y: -1)
                .translatedBy(x: 0, y: -1)
        )
        targetLayer.insertSublayer(landmarkLayer, at: 1)
    }
    
    func drawPointsOnLayer(rect:CGRect, landmarkPoints: [CGPoint], isClosed: Bool = true) -> CALayer {
        let linePath = UIBezierPath()
        linePath.move(to: landmarkPoints.first!)
        for point in landmarkPoints.dropFirst() {
            linePath.addLine(to: point)
        }
        if isClosed {
            linePath.addLine(to: landmarkPoints.first!)
        }
        let lineLayer = CAShapeLayer()
        lineLayer.path = linePath.cgPath
        lineLayer.fillColor = nil
        lineLayer.opacity = 1.0
        lineLayer.strokeColor = UIColor.green.cgColor
        lineLayer.lineWidth = 0.02
        
        return lineLayer
    }
    
    func removeMask() {
        for mask in maskLayer {
            mask.removeFromSuperlayer()
        }
        maskLayer.removeAll()
    }
    
}
