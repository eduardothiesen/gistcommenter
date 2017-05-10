//
//  NetworkRequest.swift
//  GistCommenter
//
//  Created by Eduardo Thiesen on 09/05/17.
//  Copyright © 2017 Eduardo Thiesen. All rights reserved.
//

import UIKit
import MobileCoreServices

import MobileCoreServices

class NetworkRequest: Operation, URLSessionDataDelegate {
    var sessionTask: URLSessionTask?
    var error: Error?
    var statusCode: Int?
    
    var localURLSession: URLSession? {
        return URLSession(configuration: localConfig, delegate: self, delegateQueue: nil)
    }
    
    var localConfig: URLSessionConfiguration {
        return URLSessionConfiguration.default
    }
    
    let incomingData = NSMutableData()
    
    var internalFinished: Bool = false
    
    override var isFinished: Bool {
        get {
            return internalFinished
        }
        set (newAnswer) {
            willChangeValue(forKey: "isFinished")
            internalFinished = newAnswer
            didChangeValue(forKey: "isFinished")
        }
    }
    
    func processData() {}
    func processErrorData() {}
    
    //MARK: URL Session Data
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        if isCancelled {
            isFinished = true
            sessionTask?.cancel()
            return
        }
        //Check the response code and react appropriately
        statusCode = response.value(forKey: "statusCode") as? Int
        if  statusCode != 500 {
            completionHandler(.allow)
        } else {
            completionHandler(.cancel)
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if isCancelled {
            isFinished = true
            sessionTask?.cancel()
            return
        }
        
        incomingData.append(data as Data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if isCancelled {
            isFinished = true
            task.cancel()
            return
        }
        
        if error != nil {
            self.error = error
            
            var userInfo : [String : Any] = [:]
            if (error?.localizedDescription.contains("Internet"))! {
                userInfo["Error"] = error?.localizedDescription
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kNoInternetConnection"), object: self, userInfo: userInfo)
            }
            isFinished = true
            return
        }
        
        if statusCode != 200 && statusCode != 201 {
            processErrorData()
            isFinished = true
            return
        }
        
        processData()
        isFinished = true
    }
}
