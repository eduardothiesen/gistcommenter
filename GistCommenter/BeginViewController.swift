//
//  BeginViewController.swift
//  GistCommenter
//
//  Created by Eduardo Thiesen on 09/05/17.
//  Copyright © 2017 Eduardo Thiesen. All rights reserved.
//

import UIKit

class BeginViewController: UIViewController {

    @IBOutlet var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        
        if UserDefaults.standard.bool(forKey: "receivedInvalidTokenNotification") {
            Alert.createAlert(title: "Ops, something went wrong", message: "Your session expired. Please, log in again.", viewController: self)
            
            UserDefaults.standard.set(false, forKey: "SessionExpired")
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func userDidTouchUpInsideLoginButton(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "login", sender: self)
    }

}
