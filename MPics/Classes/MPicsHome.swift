//
//  MPicsHome.swift
//  Pods
//
//  Created by Moin Pansare on 05/05/17.
//
//

import UIKit
import CoreImage

class MPicsHome: UIViewController,InitiatePhoto {
    
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var bottomContainer: UIView!
    
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var sliderView: UIView!
    
    @IBOutlet weak var mainCameraButton: UIButton!
    
    @IBOutlet weak var bottomViewHeightConstant: NSLayoutConstraint!
    
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var changeCameraButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    
    @IBOutlet weak var galleryView: UIView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var videoView: UIView!
    
    @IBOutlet weak var galleryViewXConstant: NSLayoutConstraint!
    
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    
    
    @IBOutlet var filterView: UIView!
    @IBOutlet weak var filterCollection: UICollectionView!
    var filterImageList : [UIImage] = [UIImage]();
    
    var checkFrame : CGRect = CGRect();
    var rejectFrame : CGRect = CGRect();
    var isFilterViewDisplayed : Bool = Bool(false){
        didSet{
            if isFilterViewDisplayed {
                self.checkFrame = self.checkButton.frame;
                self.rejectFrame = self.rejectButton.frame;
                displayFilterView();
            }else{
                hideFilterView();
            }
        }
    }
    
    var cameraStatus : CameraStatus = .noSelection{
        didSet{
            if cameraStatus == .noSelection {
                
                UIView.animate(withDuration: 0.5, animations: { 
                    self.filterButton.alpha = 0.0;
                    self.checkButton.alpha = 0.0;
                    self.rejectButton.alpha = 0.0;
                    
                    self.mainCameraButton.alpha = 1.0;
                    self.flashButton.alpha = 1.0;
                    self.changeCameraButton.alpha = 1.0;
                    
                })
                self.hideDisplayView();
            }else{
                
                DispatchQueue.main.async {
                    
                    UIView.animate(withDuration: 0.5, animations: { 
                        self.mainCameraButton.alpha = 0.0;
                        self.flashButton.alpha = 0.0;
                        self.changeCameraButton.alpha = 0.0;
                        
                        self.filterButton.alpha = 1.0;
                        self.checkButton.alpha = 1.0;
                        self.rejectButton.alpha = 1.0;
                    })
                    self.showDisplayView();
                }
            }
        }
    };
    
    var cameraImageSelectedDisplayView : UIImageView? = nil;
    var cameraImageSelected : UIImage? = nil;
    
    
    var MPicsDelegate : MPicsProtocol?;
    
    var pulse : CALayer = CALayer();
    var selection : MPicsSource = .camera{
        didSet{
            if self.bottomViewHeightConstant != nil {
                self.updateSliderPosition();
                self.updateFrames();
                self.updateViews();
            }
        }
    }
    
    var camersObject : Camera? = nil;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainContainer.clipsToBounds = true;
        self.cameraView.clipsToBounds = true;
        self.cameraStatus = .noSelection;
        self.filterCollection.delegate = self;
        self.filterCollection.dataSource = self;
        self.addFilerViewToBottom();
    }
    
    func addFilerViewToBottom(){
        self.filterView.frame = CGRect(x: (self.filterButton.frame.origin.x - 10 ), y: 10.0, width: 0.0, height: self.filterView.frame.size.height)
        self.filterView.backgroundColor = ColorControlColorWithTransparency;
        self.filterView.layer.cornerRadius = 5.0;
        self.filterView.alpha = 0.0;
        self.filterCollection.alpha = 0.0;
        self.bottomContainer.addSubview(self.filterView)
        self.filterCollection.backgroundColor = UIColor.clear;
        self.filterView.clipsToBounds = true;
        
    }
    
    
    func UIAdjustments(){
        self.topBar.layer.shadowColor = UIColor.white.cgColor;
        self.topBar.layer.shadowRadius = 5;
        
        self.mainContainer.layer.shadowColor = ColorMainBackground.cgColor;
        self.mainContainer.layer.shadowRadius = 5;
        
        self.bottomContainer.layer.shadowColor = UIColor.white.cgColor;
        self.bottomContainer.layer.shadowRadius = 5;
        
        self.sliderView.layer.cornerRadius = 4;
        self.sliderView.layer.shadowColor = ColorMainBackground.cgColor;
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if camersObject == nil {
            camersObject = Camera();
            camersObject?.initForView(view: self.cameraView, andController: self)
            UIAdjustments();
        }
        
        self.updateSliderPosition();
        if self.selection == .camera {
            
        }else{
            
        }
    }
    
    
    func updateSliderPosition(){
        
        if self.sliderView == nil {
            return;
        }
        
        camersObject?.stopCapture();
        
        var frame : CGRect = self.sliderView.frame;
        switch self.selection {
        case .gallery:
            frame = CGRect(x: self.galleryButton.frame.origin.x
                , y: self.sliderView.frame.origin.y, width: self.galleryButton.frame.size.width, height: self.sliderView.frame.size.height);
            break;
        case .camera:
            frame = CGRect(x: self.cameraButton.frame.origin.x
                , y: self.sliderView.frame.origin.y, width: self.cameraButton.frame.size.width, height: self.sliderView.frame.size.height);
            camersObject?.beginSession();
            break;
        case .videos:
            frame = CGRect(x: self.videoButton.frame.origin.x
                , y: self.sliderView.frame.origin.y, width: self.videoButton.frame.size.width, height: self.sliderView.frame.size.height);
            break;
        }
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
            self.sliderView.frame = frame;
        }, completion: nil)
    }
    
    func updateFrames(){
        
        switch self.selection {
        case .gallery:
            if self.bottomViewHeightConstant.constant != 0 {
                UIView.animate(withDuration: 0.5, animations: {
                    self.bottomViewHeightConstant.constant = 0;
                    self.view.layoutIfNeeded()
                    self.mainCameraButton.alpha = 0.0;
                    self.flashButton.alpha = 0.0;
                    self.changeCameraButton.alpha = 0.0;
                    self.filterButton.alpha = 0.0;
                })
            }
            
        default:
            if self.bottomViewHeightConstant.constant != 128 {
                UIView.animate(withDuration: 0.5, animations: {
                    self.bottomViewHeightConstant.constant = 128;
                    self.view.layoutIfNeeded()
                    self.mainCameraButton.alpha = 1.0;
                    self.flashButton.alpha = 1.0;
                    self.changeCameraButton.alpha = 1.0;
                    self.filterButton.alpha = 1.0;
                })
            }
            
        }
    }
    
    func updateViews(){
        switch self.selection {
        case .gallery:
            UIView.animate(withDuration: 0.5, animations: { 
                self.galleryViewXConstant.constant = 0;
                self.view.layoutIfNeeded();
            });
        case .camera:
            UIView.animate(withDuration: 0.5, animations: {
                self.galleryViewXConstant.constant = -359;
                self.view.layoutIfNeeded();
            })
        case .videos:
            UIView.animate(withDuration: 0.5, animations: {
                self.galleryViewXConstant.constant = -(359 * 2);
                self.view.layoutIfNeeded();
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    //MARK: - Button click Events
    
    @IBAction func gallerySelected(_ sender: Any) {
        self.selection = .gallery;
    }
    
    @IBAction func cameraButtonClicked(_ sender: Any) {
        self.selection = .camera;
    }
    
    @IBAction func videoButtonClicked(_ sender: Any) {
        self.selection = .videos;
    }
    
    @IBAction func mainCameraButtonClicked(_ sender: Any) {
        if self.selection == .camera {
            pulseAnimation();
            camersObject?.tappedOnCameraIcon();
        }
    }
    
    @IBAction func flashButtonClicked(_ sender: Any) {
        self.camersObject?.toggleFlashValue();
    }
    
    @IBAction func rotateCameraClicked(_ sender: Any) {
        camersObject?.rotateCamera();
    }
    @IBAction func closeButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func checkButtonClicked(_ sender: Any) {
        self.MPicsDelegate?.singleImageSnappedFromCamers(image: self.cameraImageSelected!);
        self.dismiss(animated: true, completion: {
            self.unloadAllStuff();
        })
    }
    
    @IBAction func rejectButtonClicked(_ sender: Any) {
        if self.isFilterViewDisplayed {
            self.isFilterViewDisplayed = false;
        }else{
            self.cameraStatus = .noSelection;
        }
    }
    
    @IBAction func filterButtonClicked(_ sender: Any) {
        if !self.isFilterViewDisplayed {
            self.createAllImages();
        }
        self.isFilterViewDisplayed = !self.isFilterViewDisplayed;
    }
    
    func pulseAnimation(){
        let pulse = Pulsing(numberOfPulses: 1, radius: 50, position: self.mainCameraButton.center)
        pulse.animationDuration = 0.8
        pulse.backgroundColor = ColorControlColor.cgColor
        self.bottomContainer.layer.insertSublayer(pulse, below: self.mainCameraButton.layer)
    }
    //MARK: - Camers Callbacks
    
    func photoSnapped(image: UIImage) {
        if self.selection == .camera {
            
            self.cameraImageSelected = image;
            self.cameraStatus = .imageSelected;
            
        }
    }
    
    func flashToggled(value: Bool) {
        
        let bundle = Bundle(for: self.classForCoder);
        var image : UIImage? = nil;
        if value {
            image = UIImage(named: "flash", in: bundle, compatibleWith: nil)!;
        }else{
            image = UIImage(named: "flash_off", in: bundle, compatibleWith: nil)!;
        }
        self.flashButton.setBackgroundImage(image, for: .normal)
        
    }
    
    func unloadAllStuff(){
        camersObject?.stopCapture();
    }
    
    override var prefersStatusBarHidden: Bool {
        return true;
    }
    
    
//    func simpleBlurFilterExample(inputImage: UIImage) -> (image : CIImage,orientation : UIImageOrientation,scale : CGFloat) {
//        
//        let orignalOrientation : UIImageOrientation = inputImage.imageOrientation;
//        let orignalSize : CGFloat = inputImage.scale;
//        
//        let inputCIImage = CIImage(image: inputImage)!
//        
//        let blurFilter = CIFilter(name: "CICrystallize")!
//        blurFilter.setValue(inputCIImage, forKey: kCIInputImageKey)
//        blurFilter.setValue(8, forKey: kCIInputRadiusKey)
//        
//        // Get the filtered output image and return it
//        let outputImage = blurFilter.outputImage!
//        return (ciImage: outputImage,orignalOrientation,orignalSize) as! (image: CIImage, orientation: UIImageOrientation, scale: CGFloat)
//    }
    
    func showDisplayView(){
        if cameraImageSelectedDisplayView == nil {
            self.camersObject?.stopCapture();
            self.cameraImageSelectedDisplayView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.cameraView.frame.size.width, height: self.cameraView.frame.size.height))
            self.cameraImageSelectedDisplayView?.image = self.cameraImageSelected;
            self.cameraView.addSubview(self.cameraImageSelectedDisplayView!)
        }
    }
    
    func hideDisplayView(){
        if cameraImageSelectedDisplayView != nil {
            self.camersObject?.beginSession();
            self.cameraImageSelected = nil;
            self.cameraImageSelectedDisplayView?.removeFromSuperview();
            self.cameraImageSelectedDisplayView = nil;
        }
    }
}

extension MPicsHome : UICollectionViewDelegate,UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(self.filterImageList.count);
        return self.filterImageList.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell : FilterCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionCell", for: indexPath) as! FilterCollectionCell;
        cell.myImage = self.filterImageList[indexPath.row];
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.cameraImageSelected = self.filterImageList[indexPath.row];
        self.cameraImageSelectedDisplayView?.image = self.filterImageList[indexPath.row];
    }
    
    
    func displayFilterView(){
//        if self.filterCollection.alpha == 0.0 {
        
            let rejectTempFrame : CGRect = CGRect(x: self.changeCameraButton.frame.origin.x, y: self.changeCameraButton.frame.origin.y, width: self.rejectButton.frame.size.width, height: self.rejectButton.frame.size.height);
            
            let checkTempFrame : CGRect = CGRect(x: self.flashButton.frame.origin.x, y: self.flashButton.frame.origin.y, width: self.rejectButton.frame.size.width, height: self.rejectButton.frame.size.height);
            
            let collectionWidth : CGFloat = self.bottomContainer.frame.size.width - 124.0;
            
            let collectionFrame : CGRect = CGRect(x: (self.changeCameraButton.frame.origin.x + self.checkButton.frame.size.width + 10.0) , y: 10.0, width: (collectionWidth), height: self.filterCollection.frame.size.height);
        
        print(collectionFrame);
        
        
            UIView.animate(withDuration: 0.5, animations: {
                self.checkButton.frame = checkTempFrame;
                self.rejectButton.frame = rejectTempFrame;
                self.filterCollection.alpha = 1.0;
                self.filterView.alpha = 1.0;
                self.filterView.frame = collectionFrame;

            })
            
            
//        }
    }
    
    func hideFilterView(){
//        if self.filterCollection.alpha == 1.0 {
            UIView.animate(withDuration: 0.5, animations: {
                self.checkButton.frame = self.checkFrame;
                self.rejectButton.frame = self.rejectFrame;
                self.filterCollection.alpha = 0.0;
                self.filterView.frame = CGRect(x: (self.filterButton.frame.origin.x - 10 ), y: 10.0, width: 0.0, height: self.filterView.frame.size.height)
                self.filterView.alpha = 0.0;
            })
            
            self.filterCollection.reloadData();
//        }
    }
    
    func createAllImages(){
        
        self.filterImageList.removeAll();
        self.filterImageList.append(cameraImageSelected!);
        
        var filterNames = [
            "CIPhotoEffectChrome",
            "CIPhotoEffectFade",
            "CIPhotoEffectInstant",
            "CIPhotoEffectNoir",
            "CIPhotoEffectProcess",
            "CIPhotoEffectTonal",
            "CIPhotoEffectTransfer",
            "CISepiaTone"
        ]
        
        /*
        for item in filterNames {
            
            let inputCIImage = CIImage(image: cameraImageSelected!)
            
            let blurFilter = CIFilter(name: "\(item)")!
            print(item)
            blurFilter.setValue(inputCIImage, forKey: kCIInputImageKey)
//            blurFilter.setValue(8, forKey: kCIInputRadiusKey)
            
            // Get the filtered output image and return it
            if let outputImage = blurFilter.outputImage {
                
                let finalImage = UIImage(ciImage: outputImage, scale: orignalSize, orientation: orignalOrientation)
                self.filterImageList.append(finalImage);
                
            }
        }
        */
        
        
        
        
        for item in filterNames {
            let ciContext = CIContext(options: nil)
            let coreImage = CIImage(image: cameraImageSelected!)
            let filter = CIFilter(name: "\(item)" )
            filter!.setDefaults()
            filter!.setValue(coreImage, forKey: kCIInputImageKey)
            let filteredImageData = filter!.value(forKey: kCIOutputImageKey) as! CIImage
            let filteredImageRef = ciContext.createCGImage(filteredImageData, from: filteredImageData.extent)
            let imageForButton = UIImage(cgImage: filteredImageRef!);
            self.filterImageList.append( rotateImage(image: imageForButton) );
        }
        
        self.filterCollection.reloadData();
    }
    
    func rotateImage(image : UIImage)->UIImage{
        
        let size : CGSize = image.size;
        UIGraphicsBeginImageContext(size);
        UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: UIImageOrientation.right).draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let finalImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        return finalImage;
        
    }
}



enum CameraStatus {
    case noSelection;
    case imageSelected;
}

public protocol MPicsProtocol : NSObjectProtocol {
    func singleImageSnappedFromCamers(image : UIImage);
}
