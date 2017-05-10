//
//  WelcomeTutorialViewController.swift
//  GistCommenter
//
//  Created by Eduardo Thiesen on 09/05/17.
//  Copyright © 2017 Eduardo Thiesen. All rights reserved.
//

import UIKit

class WelcomeTutorialViewController: UIViewController {

    @IBOutlet weak var tutorialPage2AspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet weak var tutorialPage3AspectRatioConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
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
        super.viewDidLayoutSubviews()
        
        //Fix interface for iPhone SE, 5 and 4
        if UIScreen.main.bounds.height <= 568 {
            tutorialPage2AspectRatioConstraint.constant = 100
            tutorialPage3AspectRatioConstraint.constant = 100
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
        
        if page == 2 {
            timer.invalidate()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        timer.invalidate()
    }
}
