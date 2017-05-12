//
//  GistViewController.swift
//  GistCommenter
//
//  Created by Eduardo Thiesen on 10/05/17.
//  Copyright © 2017 Eduardo Thiesen. All rights reserved.
//

import UIKit

class GistViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var ownerContentLabel: UILabel!
    @IBOutlet weak var descriptionContentLabel: UILabel!
    @IBOutlet weak var numberOfCommentsContentLabel: UILabel!
    @IBOutlet weak var numberOfForksContentLabel: UILabel!
    @IBOutlet weak var lastUpdateContentLabel: UILabel!
   
    @IBOutlet weak var commenterViewCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var commenterView: UIView! {
        didSet {
            commenterView.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var addNewCommentButton: UIButton!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    var gist: Gist!
    var commentsDataSource : [Comment]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        
        navigationController?.navigationBar.barStyle = .blackTranslucent
        
        ownerContentLabel.text = gist.owner
        
        descriptionContentLabel.text = gist.gistDescription
        
        numberOfCommentsContentLabel.text = String(gist.numberOfComments)
        
        numberOfForksContentLabel.text = String(gist.numberOfForks)
        
        lastUpdateContentLabel.text = gist.date?.toString()
        
        commenterView.alpha = 0.0
        commenterView.isHidden = true
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.hideKeyboards))
        self.view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GistViewController.didPostComment(notification:)),
                                               name: Notification.Name(rawValue: "kDidPostComment"), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(GistViewController.didReceiveError(notification:)),
                                               name: Notification.Name(rawValue: "kDidReceiveCommentError"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GistViewController.didReceiveInternetConnectionError(notification:)), name: NSNotification.Name(rawValue: "kNoInternetConnection"), object: nil)
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
    
    func hideKeyboards() {
        UIView.animate(withDuration: 0.25, animations: { 
            self.commenterView.alpha = 0.0
        }) { (Bool) in
            self.commenterView.isHidden = true
            self.textView.text = ""
        }
        
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func didPostComment(notification: Notification) {
        let userInfo = notification.userInfo as! [String : Comment]
        
        commentsDataSource.append(userInfo["Comment"]!)
        
        OperationQueue.main.addOperation {
            self.numberOfCommentsContentLabel.text = String(self.gist.numberOfComments + 1)
            
            self.loader.stopAnimating()
            self.enableFields()
            self.tableView.reloadData()
        }
    }
    
    func didReceiveError(notification: Notification) {
        let userInfo = notification.userInfo as! [String : Any]
        
        let expired = userInfo["expired"] as? Bool
        if let tokenExpired = expired {
            if tokenExpired {
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "beginViewController")
                
                OperationQueue.main.addOperation {
                    self.loader.stopAnimating()
                    self.enableFields()
                    self.show(viewController!, sender: self)
                }
            }
        } else {
            OperationQueue.main.addOperation {
                self.enableFields()
                self.loader.stopAnimating()
                Alert.createAlert(title: userInfo["title"] as! String?, message: userInfo["description"] as! String, viewController: self)
            }
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
    
    @IBAction func userDidTouchUpInsideBackButton(_ sender: Any) {
        hideKeyboards()
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func userDidTouchUpInsideSendCommentButton(_ sender: Any) {
        hideKeyboards()
        loader.startAnimating()
        disableFields()
        
        NetworkController.shared.postComment(id: gist.id, body: textView.text)
    }
    
    @IBAction func userDidTouchUpInsideAddNewCommentButton(_ sender: Any) {
        self.commenterViewCenterYConstraint.constant = -100
        commenterView.isHidden = false
        UIView.animate(withDuration: 0.25, animations: { 
            self.commenterView.alpha = 1.0
            self.view.layoutIfNeeded()
        }) { (Bool) in
            self.textView.becomeFirstResponder()
        }
    }
    
    func disableFields() {
        sendButton.isEnabled = false
        backButton.isEnabled = false
        addNewCommentButton.isEnabled = false
    }
    
    func enableFields() {
        sendButton.isEnabled = true
        backButton.isEnabled = true
        addNewCommentButton.isEnabled = true
    }
}

private typealias UITableViewDelegateDataSource = GistViewController
extension UITableViewDelegateDataSource: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return commentsDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentTableViewCell
        
        let comment = commentsDataSource[indexPath.row]
        
        cell.commentLabel.text = comment.body
        if let link = comment.avatar {
            cell.avatarImageView.downloadedFrom(link: link, contentMode: .scaleAspectFill)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}
