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
    @IBOutlet weak var loadingScreen: UIActivityIndicatorView!
    
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

    var gist: Gist!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .authorized {
            showAuthorizedScreen()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.didReceiveGist(notification:)),
                                               name: Notification.Name(rawValue: "kDidReceiveGist"), object: nil)

        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.didReceiveError(notification:)),
                                               name: Notification.Name(rawValue: "kDidReceiveGistError"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.didReceiveInternetConnectionError(notification:)), name: NSNotification.Name(rawValue: "kNoInternetConnection"), object: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        
        accessButton.setTitle("Start Camera", for: .normal)
        captureSession?.stopRunning()
        videoPreviewLayer?.removeFromSuperlayer()
        cameraLensIndicator?.removeFromSuperview()
        loadingScreen.stopAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nav = segue.destination as! UINavigationController
        let gvc = nav.topViewController as! GistViewController
        
        gvc.gist = self.gist

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
            loadingScreen.stopAnimating()
        }
    }
    
    func didReceiveGist(notification: Notification) {
        let userInfo = notification.userInfo as! [String : Gist]
        
        self.gist = userInfo["Gist"]
        
        OperationQueue.main.addOperation { 
            self.performSegue(withIdentifier: "gist", sender: self)
        }
    }
    
    func didReceiveError(notification: Notification) {
        let userInfo = notification.userInfo as! [String : Any]
        
        let expired = userInfo["expired"] as? Bool
        if let tokenExpired = expired {
            if tokenExpired {
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "beginViewController")
                
                OperationQueue.main.addOperation {
                    self.show(viewController!, sender: self)
                }
            }
        } else {
            OperationQueue.main.addOperation {
                self.loadingScreen.stopAnimating()
                Alert.createAlert(title: userInfo["title"] as! String?, message: userInfo["description"] as! String, viewController: self)
            }
            
            captureSession?.startRunning()
        }
    }
    
    func didReceiveInternetConnectionError(notification: Notification) {
        let userInfo = notification.userInfo as! [String : Any]
        
        OperationQueue.main.addOperation {
            self.loadingScreen.stopAnimating()
    
            let alertController = UIAlertController(title: "", message: userInfo["Error"] as? String, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) in
                self.captureSession?.startRunning()
            })
            
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
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
            self.view.bringSubview(toFront: loadingScreen)
            loadingScreen.startAnimating()
            
            captureSession?.stopRunning()
            let gistString = metadataObj.stringValue!
            var gistId : String!
            if gistString.contains("http") {
                gistId = gistString.components(separatedBy: "/").last
            } else {
                gistId = gistString
            }
            
            print(gistId)
            NetworkController.shared.retrieveGist(id: gistId)
        }
    }
}

