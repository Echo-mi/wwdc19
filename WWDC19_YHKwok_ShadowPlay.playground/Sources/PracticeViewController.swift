//
//  LearnViewController.swift
//
//  Created by Yu Ho Kwok on 20/3/2019.
//  Copyright © 2019 @Will Kwok. All rights reserved.
//

import UIKit
import AVFoundation
import CoreImage
import Vision

@objc
open class PracticeViewController : UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
     let model = HandShadow().model
    
    var previewImageView : UIImageView?
    var button : UIButton?
    
    var statusLabel : UILabel?
    var predictLabel : UILabel?
    
    var captureSession : AVCaptureSession!
    var captureDevice : AVCaptureDevice?
    
    private var sampleBufferQueue = DispatchQueue.global(qos: .userInteractive)
    
    private var currentLearn = "🐇"
    
    private var isCameraStart = false
    
    let nameEmojiDict = ["dog":"🐕", "rabbit":"🐇", "camel":"🐪", "chimpanzee":"🦍"]
    
    open func setupUI(){
        
        print("setup ui")
        statusLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 320, height: 20))
        statusLabel?.textColor = UIColor.white
        statusLabel?.text = "Shadow Play"
        
        predictLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 320, height: 20))
        predictLabel?.textColor = UIColor.white
        predictLabel?.text = "🤷🤷‍♂️"
        
        previewImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        previewImageView?.contentMode = .scaleAspectFill

        
        button = UIButton(type: .roundedRect)
        button?.frame = CGRect(x: 0, y: 0, width: 80, height: 40)
        button?.setTitle("💡", for: .normal)
        button?.addTarget(self, action: #selector(LearnViewController.lightOnClicked), for: .touchUpInside)
        button?.isHidden = true
        
        
        self.view.addSubview(self.previewImageView!)
        self.view.addSubview(self.statusLabel!)
        self.view.addSubview(self.predictLabel!)
        self.view.addSubview(self.button!)
        
        self.statusLabel?.text = "width: \(self.view.bounds.size.width)"
    }
    
    @objc
    func lightOnClicked(){
        do {
            try captureDevice?.lockForConfiguration()
            if captureDevice?.isTorchActive == false {
                self.statusLabel?.text = "Light On"
                try captureDevice?.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
            } else {
                self.statusLabel?.text = ""
                captureDevice?.torchMode = .off
            }
            captureDevice?.unlockForConfiguration()
        } catch {
            
        }
    }
    
    open func startCamera(){
        #if (arch(i386) || arch(x86_64)) && os(iOS)
        print("can't use camera on xcode")
        statusLabel?.text = "can't use camera on xcode"
        #else
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.vga640x480
        //cameraOutput = AVCapturePhotoOutput()
        
        let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)
        self.captureDevice = device
        //AVCaptureDevice.default(for: AVMediaType.video)
        
        if let input = try? AVCaptureDeviceInput(device: device!) {
            if(captureSession.canAddInput(input)) {
                captureSession.addInput(input)
                
                let output = AVCaptureVideoDataOutput()
                output.alwaysDiscardsLateVideoFrames = true
                output.setSampleBufferDelegate(self, queue: sampleBufferQueue)
                if(captureSession.canAddOutput(output)) {
                    print("output added")
                    captureSession.addOutput(output)
                }
                
                captureSession.startRunning()
                
            } else {
                print("could not add the input")
                statusLabel?.text = "could not add the input"
            }
        } else {
            print("could not find an input")
            statusLabel?.text = "could not find an input"
        }
        #endif
    }
    
    open func hasTouch() -> Bool {
        return (captureDevice?.hasTorch == true && captureDevice?.isTorchAvailable == true)
    }
    
    let context = CIContext(options: nil)
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        print("output")
        guard let apixeBuffer : CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return}
        DispatchQueue.global().async {
            
            
            
            let image = CIImage(cvImageBuffer: apixeBuffer)
            let cgImage = self.context.createCGImage(image, from: image.extent)
            let uiImage = UIImage(cgImage: cgImage!, scale: 1.0, orientation: .up)
            
            DispatchQueue.main.async {
                self.previewImageView?.image = uiImage
            }
            
            // use the image as input to feed the model (use its URL)
            let model = try! VNCoreMLModel(for: self.model)
            let request = VNCoreMLRequest(model: model, completionHandler: self.predictionCompleted)
            request.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
            let requestHandler = VNImageRequestHandler(cvPixelBuffer: apixeBuffer)
            
            try! requestHandler.perform([request])
        }
    }
    
    func predictionCompleted(request: VNRequest, error: Error?) {
        
        guard let results = request.results as? [VNClassificationObservation] else {
            fatalError("could not get any prediction output from ML model")
        }
        
        var bestPrediction = ""
        var confidence: VNConfidence = 0
        
        print("===")
        for classification in results {
            if classification.confidence > confidence {
                confidence = classification.confidence
                bestPrediction = classification.identifier
                print("= \(classification.identifier): \(classification.confidence)")
            }
        }
        
        DispatchQueue.main.async {
            self.predictLabel?.text = self.nameEmojiDict[bestPrediction]
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("did layout subviews \(self.view.bounds.size.width)")
        
        
        //self.statusLabel?.text = "width: \(self.view.bounds.size.width)"
        self.statusLabel?.text = ""
        
        self.previewImageView?.frame = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.size.width, height: self.view.bounds.size.width)
        self.previewImageView?.center = self.view.center

        self.predictLabel?.frame = CGRect(x: 0, y: self.view.bounds.size.height-50-30, width: self.view.bounds.size.width, height: 50)
        self.predictLabel?.textAlignment = .center
        self.predictLabel?.font = UIFont.systemFont(ofSize: 50)

        self.button?.center = CGPoint(x: self.view.bounds.size.width - 40, y: self.view.bounds.size.height - 40)
        
        if isCameraStart == false {
            self.isCameraStart = true
            self.startCamera()
            
            if self.hasTouch() {
                self.button?.isHidden = false
            }
        }
        
        
    }
}
