//
//  WelcomeTutorialViewController.swift
//  GistCommenter
//
//  Created by Eduardo Thiesen on 09/05/17.
//  Copyright © 2017 Eduardo Thiesen. All rights reserved.
//

import UIKit

class WelcomeTutorialViewController: UIViewController {

    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var pageControl: UIPageControl!
    
    @IBOutlet var page1Label: UILabel!
    @IBOutlet var page2Label: UILabel!
    @IBOutlet var page3Label: UILabel!
    
    @IBOutlet var leadingSpacePage1LabelConstraint: NSLayoutConstraint!
    @IBOutlet var trailingSpacePage1LabelConstraint: NSLayoutConstraint!
    @IBOutlet var leadingSpacePage2LabelConstraint: NSLayoutConstraint!
    @IBOutlet var trailingSpacePage2LabelConstraint: NSLayoutConstraint!
    @IBOutlet var leadingSpacePage3LabelConstraint: NSLayoutConstraint!
    @IBOutlet var trailingSpacePage3LabelConstraint: NSLayoutConstraint!
    
    @IBOutlet var page1widthConstraint: NSLayoutConstraint!
    @IBOutlet var page2widthConstraint: NSLayoutConstraint!
    @IBOutlet var page3widthConstraint: NSLayoutConstraint!
    
    @IBOutlet var page1topSpaceToLabelConstraint: NSLayoutConstraint!
    @IBOutlet var page2topSpaceToLabelConstraint: NSLayoutConstraint!
    @IBOutlet var page3topSpaceToLabelConstraint: NSLayoutConstraint!
    
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
        
        timer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(WelcomeTutorialViewController.showNextTutorialPage), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        if UIScreen.main.bounds.height == 480 {
            page1Label.font = UIFont(name: "HelveticaNeue-Medium", size: 20.0)
            page2Label.font = UIFont(name: "HelveticaNeue-Medium", size: 20.0)
            page3Label.font = UIFont(name: "HelveticaNeue-Medium", size: 19.0)
            
            page1topSpaceToLabelConstraint.constant = 8
            page2topSpaceToLabelConstraint.constant = 8
            page3topSpaceToLabelConstraint.constant = 8
            
            leadingSpacePage1LabelConstraint.constant = 12
            trailingSpacePage1LabelConstraint.constant = 12
            leadingSpacePage2LabelConstraint.constant = 12
            trailingSpacePage2LabelConstraint.constant = 12
            leadingSpacePage3LabelConstraint.constant = 12
            trailingSpacePage3LabelConstraint.constant = 12
            
            page1widthConstraint.constant = -60
            page2widthConstraint.constant = -60
            page3widthConstraint.constant = -65
        } else if UIScreen.main.bounds.height == 568 {
            leadingSpacePage3LabelConstraint.constant = 16
            trailingSpacePage3LabelConstraint.constant = 16
            
            page1widthConstraint.constant = -25
            page2widthConstraint.constant = -25
            page3widthConstraint.constant = -25
        }
        
        self.view.layoutIfNeeded()
    }
    
    func showNextTutorialPage() {
        let x = scrollView.contentOffset.x
        let y = scrollView.contentOffset.y
        
        scrollView.setContentOffset(CGPoint(x: x + scrollView.frame.size.width, y: y), animated: true)
    }
}

extension WelcomeTutorialViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = ceil( (scrollView.contentOffset.x / scrollView.frame.size.width))
        pageControl.currentPage = Int(page)
        
        if page == 3 {
            timer.invalidate()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        timer.invalidate()
    }
}
