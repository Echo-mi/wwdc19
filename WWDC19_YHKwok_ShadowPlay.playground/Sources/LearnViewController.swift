//
//  LearnViewController.swift
//
//  Created by Yu Ho Kwok on 20/3/2019.
//  Copyright © 2019 @Will Kwok. All rights reserved.
//

import UIKit
import AVFoundation
import CoreImage

@objc
open class LearnViewController : UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var previewImageView : UIImageView?
    var learnImageView : UIImageView?
    var button : UIButton?
    var segmentedControl : UISegmentedControl?
    
    var statusLabel : UILabel?
    
    var captureSession : AVCaptureSession!
    var captureDevice : AVCaptureDevice?
    
    private var sampleBufferQueue = DispatchQueue.global(qos: .userInteractive)
    
    private var currentLearn = "🐇"
    
    private var isCameraStart = false
    
    let photos = ["hand.png", "camel.png", "chimpanzee.png", "dog.png"]
    
    open func setupUI(){
        
        print("setup ui")
        statusLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 320, height: 20))
        statusLabel?.textColor = UIColor.white
        statusLabel?.text = "Shadow Play"
        
        previewImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        previewImageView?.contentMode = .scaleAspectFill
        
//        previewImageView?.backgroundColor = .white
        
        learnImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        learnImageView?.contentMode = .scaleAspectFit
        
        button = UIButton(type: .roundedRect)
        button?.frame = CGRect(x: 0, y: 0, width: 80, height: 40)
        button?.setTitle("💡", for: .normal)
        button?.addTarget(self, action: #selector(LearnViewController.lightOnClicked), for: .touchUpInside)
        button?.isHidden = true
        
        segmentedControl = UISegmentedControl(frame: CGRect(x: 0, y: 20, width: 250, height: 20))
        
        segmentedControl?.insertSegment(withTitle: "🐕", at: 0, animated: false)
        segmentedControl?.insertSegment(withTitle: "🦍", at: 0, animated: false)
        segmentedControl?.insertSegment(withTitle: "🐪", at: 0, animated: false)
        segmentedControl?.insertSegment(withTitle: "🐇", at: 0, animated: false)
        segmentedControl?.selectedSegmentIndex = 0
        segmentedControl?.addTarget(self, action: #selector(LearnViewController.segmented), for: .valueChanged)
        
        self.view.addSubview(self.previewImageView!)
        self.view.addSubview(self.learnImageView!)
        self.view.addSubview(self.statusLabel!)

        self.view.addSubview(self.segmentedControl!)
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
    
    @objc
    func segmented(){
        if let index = self.segmentedControl?.selectedSegmentIndex {
            print("yo :\(index)")
            let name = photos[index]
            let img = UIImage(named: name)!
            self.learnImageView?.image = img
        }
    }

    
    open func startCamera(){
        #if (arch(i386) || arch(x86_64)) && os(iOS)
        print("can't use camera on xcode")
        statusLabel?.text = "can't use camera on xcode"
        #else
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.high
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
                self.view.bringSubviewToFront(self.learnImageView!)
            }
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("did layout subviews \(self.view.bounds.size.width)")
        
        //self.statusLabel?.text = "width: \(self.view.bounds.size.width)"
        self.statusLabel?.text = ""
        
        self.previewImageView?.frame = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.size.width, height: self.view.bounds.size.width)
        self.previewImageView?.center = self.view.center
        
        self.learnImageView?.frame = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.size.width, height: self.view.bounds.size.width)
        self.learnImageView?.center = self.view.center
        self.learnImageView?.backgroundColor = .clear
        
        self.segmentedControl?.center = CGPoint(x: self.view.center.x, y: self.view.bounds.size.height - 40)
        
        self.button?.center = CGPoint(x: self.view.bounds.size.width - 40, y: self.view.bounds.size.height - 40)

        if isCameraStart == false {
            self.isCameraStart = true
            self.startCamera()

            let img = UIImage(named: "hand.png")!
            self.learnImageView?.image = img

            if self.hasTouch() {
                self.button?.isHidden = false
            }
        }
        
        
    }
}

extension LearnViewController {

    
    func getResolvedOrientation() -> UIImage.Orientation {
        switch(UIDevice.current.orientation) {
        case .landscapeLeft: return .up
        case .landscapeRight: return .down
        case .portrait: return .right
        default: return .left
        }
    }
}

extension AVCaptureVideoOrientation {
    
    
    var uiInterfaceOrientation: UIInterfaceOrientation {
        get {
            switch self {
            case .landscapeLeft:        return .landscapeLeft
            case .landscapeRight:       return .landscapeRight
            case .portrait:             return .portrait
            case .portraitUpsideDown:   return .portraitUpsideDown
            }
        }
    }
    
    init(ui:UIInterfaceOrientation) {
        switch ui {
        case .landscapeRight:       self = .landscapeRight
        case .landscapeLeft:        self = .landscapeLeft
        case .portrait:             self = .portrait
        case .portraitUpsideDown:   self = .portraitUpsideDown
        default:                    self = .portrait
        }
    }
}
