//
//  LoginViewController.swift
//  GistCommenter
//
//  Created by Eduardo Thiesen on 09/05/17.
//  Copyright © 2017 Eduardo Thiesen. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet var usernameTextField: CustomTextField!
    @IBOutlet var passwordTextField: CustomTextField!
    @IBOutlet var loader: UIActivityIndicatorView!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.hideKeyboards))
        self.view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.didAuthenticateSuccefully(notification:)), name: NSNotification.Name(rawValue: "kDidAuthenticateUser"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.didReceiveAuthenticationError(notification:)), name: NSNotification.Name(rawValue: "kDidReceiveLoginError"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.didReceiveInternetConnectionError(notification:)), name: NSNotification.Name(rawValue: "kNoInternetConnection"), object: nil)
        
        usernameTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func userDidTouchUpInsideLoginButton(_ sender: AnyObject) {
        if usernameTextField.text != "" && passwordTextField.text != "" {
            loader.startAnimating()
            disableFields()
            
            NetworkController.shared.login(username: usernameTextField.text!, password: passwordTextField.text!)
        } else {
            Alert.createAlert(title: "Enter username and password", message: "All fields are required for authentication", viewController: self)
        }

    }
    
    @IBAction func userDidTouchUpInsideBackButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    

    func enableFields() {
        usernameTextField.isEnabled = true
        passwordTextField.isEnabled = true
        loginButton.isEnabled = true
        backButton.isEnabled = true
    }
    
    func disableFields() {
        usernameTextField.isEnabled = false
        passwordTextField.isEnabled = false
        loginButton.isEnabled = false
        backButton.isEnabled = false
    }
    
    func hideKeyboards() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func didAuthenticateSuccefully(notification: Notification) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MainView")
        
        OperationQueue.main.addOperation {
            self.enableFields()
            self.loader.stopAnimating()
            
            self.show(viewController!, sender: viewController)
        }
    }
    
    func didReceiveInternetConnectionError(notification: Notification) {
        let userInfo = notification.userInfo as! [String : Any]
        
        OperationQueue.main.addOperation {
            self.enableFields()
            self.loader.stopAnimating()
            Alert.createAlert(title: "", message: userInfo["Error"] as! String, viewController: self)
        }
    }
    
    func didReceiveAuthenticationError(notification: Notification) {
        let userInfo = notification.userInfo as! [String : Any]
        
        OperationQueue.main.addOperation {
            Alert.createAlert(title: userInfo["title"] as! String?, message: userInfo["description"] as! String, viewController: self)
            
            self.enableFields()
            self.loader.stopAnimating()
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            passwordTextField.resignFirstResponder()
            userDidTouchUpInsideLoginButton(self)
        }
        
        return true
    }
}
