//
//  ViewController.swift
//  KangooBear
//
//  Created by Eytan Schulman on 1/23/16.
//  Copyright © 2016 MultiEducator. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    @IBOutlet var userNameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    
    @IBAction func logInAction() {
//        sendRequest(<#T##parameters: [String : String]##[String : String]#>)
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