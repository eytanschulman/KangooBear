//
//  ViewController.swift
//  KangooBear
//
//  Created by Eytan Schulman on 1/23/16.
//  Copyright © 2016 MultiEducator. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController,UIWebViewDelegate {
    
    @IBOutlet var userNameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    
    @IBAction func signIn() {
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
                let rightRange = Range<String.Index>(start: (h3Location?.endIndex)!, end: (rangeOfBracket?.endIndex)!)
                let JSONString = html.substringWithRange(rightRange)
                
                let withoutBackN = JSONString.stringByReplacingOccurrencesOfString("\n", withString: "")
                
                let withoutEscapedQuotes = withoutBackN.stringByReplacingOccurrencesOfString("\\\"", withString: "\"")
                
                self.performSegueWithIdentifier("MoreInfoSegue", sender: withoutEscapedQuotes)
                
                /*
"{        \"access_token\":\"GY1Pk9wtA2A9IzJeNUsNbf1doha0\",         \"scope\":\"subscription read:healthdata\",         \"token_type\":\"BearerToken\"}"
*/
                
                //                let newRange = h3Location[4]
                //                let newRange = html.substringWithRange(Range<String.Index>(h3Location))
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "MoreInfoSegue" {
            let destVC = (segue.destinationViewController as? UINavigationController)?.topViewController as? ExtraInfoViewController
            if let pJSONString = sender as? String {
                destVC?.passedJSONString = pJSONString
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