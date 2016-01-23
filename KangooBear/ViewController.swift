//
//  ViewController.swift
//  KangooBear
//
//  Created by Eytan Schulman on 1/23/16.
//  Copyright © 2016 MultiEducator. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController,UIWebViewDelegate {
    
    @IBOutlet var userNameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    
    @IBAction func patientLogIn() {
        showLogInUI()
    }
    
    func showLogInUI() {
        let webView = UIWebView(frame: CGRect(x: 0, y: 60, width: self.view.frame.size.width, height: self.view.frame.size.height - 20))
        let url = NSURL(string: "https://jnj-dev.apigee.net/otr/oauth2/authorize?client_id=uZI5ipSGkkLBEXplEpOAjVBU1ODVzZyP")
        if let realURL = url {
            webView.loadRequest(NSURLRequest(URL:realURL))
            webView.delegate = self
            self.view.addSubview(webView)
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if let html = webView.stringByEvaluatingJavaScriptFromString("document.body.innerHTML") {
            if html.containsString("access_token") {
                //WHOO THIS SHOULD BE GOOD
                print("OMG IS IT PRINTING?")
                let h3Location = html.rangeOfString("</h3>")
                let rangeOfBracket = html.rangeOfString("}")
                let rightRange = Range<String.Index>(start: (h3Location?.endIndex)!, end: (rangeOfBracket?.startIndex)!)
                let JSONString = html.substringWithRange(rightRange)
                print(html)
                print(h3Location)
                print(JSONString)
                //                let newRange = h3Location[4]
                //                let newRange = html.substringWithRange(Range<String.Index>(h3Location))
            }
        }
    }
    
    @IBAction func doctorLogIn() {
        self.performSegueWithIdentifier("PatientListSegue", sender: nil)
    }
    
    func sendRequest(parameters: [String: String]) {
        
        let headers = ["Content-Type":"application/json"]
        
        let encoding = Alamofire.ParameterEncoding.JSON
        
        Alamofire.request(.POST, "",parameters: parameters, headers:headers, encoding: encoding).validate(statusCode: 200..<300)
            .responseJSON{(response) in
                
                print(response.request)  // original URL request
                print(response.response) // URL response
                print(response.data)     // server data
                print(response.result)   // result of response serialization
                print(response.request?.HTTPBody)
                
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                }
                
                print(response.result.value)
                
                if let rs = response.result.value as? Dictionary<String,Int> {
                    print(rs)
                    
                    if let status = rs["status"] {
                        let ac = UIAlertController(title: NSLocalizedString("Information Successfully Uploaded", comment: ""), message: nil, preferredStyle: .Alert)
                        let action = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .Cancel, handler: nil)
                        ac.addAction(action)
                        print(status)
                        self.presentViewController(ac, animated: true, completion: nil)
                    }
                }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}