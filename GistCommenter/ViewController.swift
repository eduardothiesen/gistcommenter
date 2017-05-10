//
//  ViewController.swift
//  GistCommenter
//
//  Created by Eduardo Thiesen on 09/05/17.
//  Copyright © 2017 Eduardo Thiesen. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var accessButton: UIButton!
    @IBOutlet weak var welcomeMessageLabel: UILabel!
    @IBOutlet weak var welcomeTitleLabel: UILabel!
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var cameraLensIndicator: UIImageView?
    
    let supportedCodeTypes = [AVMetadataObjectTypeUPCECode,
                              AVMetadataObjectTypeCode39Code,
                              AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeCode93Code,
                              AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypeEAN8Code,
                              AVMetadataObjectTypeEAN13Code,
                              AVMetadataObjectTypeAztecCode,
                              AVMetadataObjectTypePDF417Code,
                              AVMetadataObjectTypeQRCode]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .authorized {
            showAuthorizedScreen()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func userDidTouchUpInsideGrantPermissionButton(_ sender: Any) {
        if accessButton.titleLabel?.text == "Grant Permission" {
            requestCameraAccess()
        } else if accessButton.titleLabel?.text == "Start Camera" {
            startCamera()
        } else if accessButton.titleLabel?.text == "Stop Camera" {
            accessButton.setTitle("Start Camera", for: .normal)
            captureSession?.stopRunning()
            videoPreviewLayer?.removeFromSuperlayer()
            cameraLensIndicator?.removeFromSuperview()
        }
    }
    
    func requestCameraAccess() {
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted :Bool) -> Void in
            if granted == true {
               self.showAuthorizedScreen()

            } else {
                OperationQueue.main.addOperation({ 
                    let alertController = UIAlertController(title: "Camera Access Required", message: "To use the app you must grant access to your camera", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    let confirmAction = UIAlertAction(title: "Settings", style: .default, handler: { (UIAlertAction) in
                        let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
                        UIApplication.shared.openURL(settingsUrl!)
                        
                    })
                    
                    alertController.addAction(cancelAction)
                    alertController.addAction(confirmAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                })
            }
        });
    }
    
    func startCamera() {
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
        
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            captureSession?.startRunning()
            
            accessButton.setTitle("Stop Camera", for: .normal)
            view.bringSubview(toFront: accessButton)
            
            cameraLensIndicator = UIImageView(image: UIImage(named: "camera_indicator"))
            cameraLensIndicator?.center = view.center
            view.addSubview(cameraLensIndicator!)
            view.bringSubview(toFront: cameraLensIndicator!)
            
        } catch {
            print(error)
            return
        }
    }
    
    func showAuthorizedScreen() {
        welcomeTitleLabel.isHidden = true
        welcomeMessageLabel.text = "Are you ready? (:\n\nScan a QR Code containing a link to a gist or its id"
        accessButton.setTitle("Start Camera", for: .normal)
    }
}

private typealias AVCaptureMetadataOutputObjects = ViewController
extension AVCaptureMetadataOutputObjects: AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            //If does not capture QR Code, keep scanning (do nothing)
            return
        }

        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            captureSession?.stopRunning()
            let gistString = metadataObj.stringValue!
            var gistId : String!
            if gistString.contains("http") {
                gistId = gistString.components(separatedBy: "/").last
            } else {
                gistId = gistString
            }
            
            print(gistId)
            
        }
    }
}

