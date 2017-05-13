//
//  Camera.swift
//  Pods
//
//  Created by Moin Pansare on 05/05/17.
//
//

import UIKit
import Photos

class Camera: NSObject,AVCaptureVideoDataOutputSampleBufferDelegate {

    var cameraDelegate : InitiatePhoto?;
    var viewForCamera: UIView = UIView();
    var cameraLoaded : Bool = false;
    var takePhoto : Bool = false;
    
    var cameraSession : AVCaptureSession = AVCaptureSession();
    var myLayer : CALayer!;
    var captureDevices : AVCaptureDevice!;
    
    var cameraPosition : AVCaptureDevicePosition! = AVCaptureDevicePosition.back
    
    var currentState : cameraState = .isRunning;
    
    var isFlashOn : Bool = false;
    
    override init() {
        
    }
    
    func initForView(view : UIView, andController delegate : InitiatePhoto){
        self.viewForCamera = view;
        self.cameraDelegate = delegate;
        
        if !cameraLoaded{
            cameraLoaded = true;
            loadCamera();
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        if takePhoto {
            takePhoto = false;
            if let imageRecieved = self.getImageFromBuffer(sampleBuffer: sampleBuffer){
                self.cameraDelegate?.photoSnapped(image: imageRecieved)
            }
        }
    }
    
    
    func getImageFromBuffer(sampleBuffer : CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer){
            if #available(iOS 9.0, *) {
                let ciImage = CIImage(cvImageBuffer: pixelBuffer)
                let myContext = CIContext();
                let imageFrame = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
                if let image = myContext.createCGImage(ciImage, from: imageFrame){
                    return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right);
                }
            } else {
                // Fallback on earlier versions
            };
            
        }
        return nil;
    }
    
    
    
    func loadCamera(){
        cameraSession.sessionPreset = AVCaptureSessionPresetPhoto;
        
        if #available(iOS 10.0, *) {
            if let availableDevices = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: cameraPosition).devices{
                captureDevices = availableDevices.first;
            }
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    
    
    func beginSession(){
        
        if currentState == .isRunning {
            return;
        }
        
        currentState = .isRunning;
        
        do{
            let captureDeviceInput : AVCaptureDeviceInput! = try AVCaptureDeviceInput(device: captureDevices)
            cameraSession.addInput(captureDeviceInput);
        }catch{
            print("error " + error.localizedDescription)
        }
        
        if let previewLayer : CALayer = AVCaptureVideoPreviewLayer(session: cameraSession){
            self.myLayer = previewLayer;
            
            myLayer.frame = CGRect(x: -50, y: -50, width: self.viewForCamera.frame.size.width + 100, height: self.viewForCamera.frame.size.height + 100);
            self.viewForCamera.layer.insertSublayer(myLayer, at: 0)
            cameraSession.startRunning();
        }
        
        let dataOutputSession : AVCaptureVideoDataOutput = AVCaptureVideoDataOutput();
        dataOutputSession.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)];
        
        dataOutputSession.alwaysDiscardsLateVideoFrames = true;
        
        if cameraSession.canAddOutput(dataOutputSession){
            cameraSession.addOutput(dataOutputSession);
        }
        
        cameraSession.commitConfiguration();
        
        let myQueue = DispatchQueue(label: "com.moin.myCameraQueue");
        dataOutputSession.setSampleBufferDelegate(self, queue: myQueue);
        
    }
    
    func rotateCamera(){
        if cameraPosition == AVCaptureDevicePosition.back {
            cameraPosition = AVCaptureDevicePosition.front;
        }else{
            cameraPosition = AVCaptureDevicePosition.back;
        }
        self.stopCapture();
        myLayer.removeFromSuperlayer();
        loadCamera();
        self.beginSession()
    }
    
    func initiateFlash(){
        if captureDevices.hasFlash && self.isFlashOn {
            do {
                try captureDevices.lockForConfiguration();
                captureDevices.torchMode = AVCaptureTorchMode(rawValue: 1)!
                captureDevices.unlockForConfiguration()
                cameraSession.commitConfiguration()
            }catch{
                print("No Flash");
            }
        }
    }
    
    func toggleFlashValue(){
        
        self.isFlashOn = !self.isFlashOn;
        cameraDelegate?.flashToggled(value: self.isFlashOn);
        
    }
    
    func stopCapture(){
        
        if currentState == .isStopped {
            return;
        }
        
        currentState = .isStopped;
        
    
        self.cameraSession.stopRunning();
        if let input = self.cameraSession.inputs as? [AVCaptureDeviceInput] {
            for item in input {
                self.cameraSession.removeInput(item)
            }
        }
        
        if let output = self.cameraSession.outputs as? [AVCaptureVideoDataOutput] {
            for item in output{
                self.cameraSession.removeOutput(item)
            }
        }
        if (self.myLayer) != nil {
            self.myLayer.removeFromSuperlayer();
        }
        
        
    }
    
    func tappedOnCameraIcon(){
        if self.isFlashOn {
            self.initiateFlash();
            let when = DispatchTime.now() + 0.5 // change 2 to desired number of seconds
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.takePhoto = true;
            }
        }else{
            self.takePhoto = true;
        }
        
    }

    
    
}

protocol InitiatePhoto : NSObjectProtocol {
    func photoSnapped(image : UIImage);
    func flashToggled(value : Bool);
}

enum cameraState {
    case isRunning;
    case isStopped;
}
