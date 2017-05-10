//
//  LoginViewController.swift
//  GistCommenter
//
//  Created by Eduardo Thiesen on 09/05/17.
//  Copyright © 2017 Eduardo Thiesen. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet var emailTextField: CustomTextField!
    @IBOutlet var passwordTextField: CustomTextField!
    @IBOutlet var loader: UIActivityIndicatorView!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var backButton: UIButton!
    
//    var networkController : NetworkController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        loginButton.setTitle("Entrar", for: .normal)
        
//        networkController = NetworkController()
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.didReceiveAuthenticationError(notification:)), name: NSNotification.Name(rawValue: "kDidReceiveLoginError"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.didReceiveInternetConnectionError(notification:)), name: NSNotification.Name(rawValue: "kNoInternetConnection"), object: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func userDidTouchUpInsideLoginButton(_ sender: AnyObject) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            loader.startAnimating()
            disableFields()
            
//            networkController.login(email: emailTextField.text!, password: passwordTextField.text!)
        } else {
//            Alert.createAlert(title: "Atenção", message: "Você precisa preencher o e-mail e senha para se logar.", viewController: self)
        }

    }
    
    @IBAction func userDidTouchUpInsideBackButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    

    func enableFields() {
        emailTextField.isEnabled = true
        passwordTextField.isEnabled = true
        loginButton.isEnabled = true
        backButton.isEnabled = true
    }
    
    func disableFields() {
        emailTextField.isEnabled = false
        passwordTextField.isEnabled = false
        loginButton.isEnabled = false
        backButton.isEnabled = false
    }
    
    func didReceiveInternetConnectionError(notification: Notification) {
        let userInfo = notification.userInfo as! [String : Any]
        
        OperationQueue.main.addOperation {
            self.enableFields()
            self.loader.stopAnimating()
//            Alert.createAlert(title: "", message: userInfo["Error"] as! String, viewController: self)
        }
    }
    
    func didReceiveAuthenticationError(notification: Notification) {
        let userInfo = notification.userInfo as! [String : Any]
        print(userInfo["title"] as! String?)
        print(userInfo["description"] as! String?)
        
        OperationQueue.main.addOperation {
//            Alert.createAlert(title: userInfo["title"] as! String?, message: userInfo["description"] as! String, viewController: self)
            
            self.enableFields()
            self.loader.stopAnimating()
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            passwordTextField.resignFirstResponder()
        }
        
        return true
    }
}
