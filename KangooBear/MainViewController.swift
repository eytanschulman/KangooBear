//
//  MainViewController.swift
//  KangooBear
//
//  Created by Eytan Schulman on 1/23/16.
//  Copyright © 2016 MultiEducator. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MainViewController: UIViewController {

    @IBOutlet var dosageLevelLabel: UILabel!
    @IBOutlet var noPrescriptionView: UIView!
    @IBOutlet var hasPrescriptionView: UIView!
    @IBOutlet var costLabel: UILabel!
    @IBOutlet var deliveryTimeLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        sendRequest()
    }
    
    @IBAction func performRequest() {
        
    }
    
    func sendRequest() {
        
//        let headers = ["Content-Type":"application/json"]
        
//        let encoding = Alamofire.ParameterEncoding.JSON
        
        if let userID = NSUserDefaults.standardUserDefaults().objectForKey("userID") as? String! {
            
            let url = NSURL(string: "http://kangoobear.herokuapp.com/api/patients/\(userID)")
            if let u = url {
                let patientData = NSData(contentsOfURL: u)
                let json = JSON(data: patientData!)
                
                let userDefaults = NSUserDefaults.standardUserDefaults()
                userDefaults.setObject(json["patients"]["dosage"].stringValue, forKey: "dosage")
                userDefaults.setObject(json["patients"]["cost"].stringValue, forKey: "cost")
                userDefaults.setObject(json["patients"]["deliveryTime"].stringValue, forKey: "deliveryTime")
                userDefaults.setObject(json["patients"]["address"].stringValue, forKey: "address")
                print(json)
                
                if Int(json["patients"]["dosage"].stringValue.stringByReplacingOccurrencesOfString("IU", withString: "")) == 100 {
                    //NO PRESCRIPTIONS
                    self.noPrescriptionView.hidden = false
                    self.hasPrescriptionView.hidden = true
                } else {
                    //HAS PRESCRIPTIONS
                    self.noPrescriptionView.hidden = true
                    self.hasPrescriptionView.hidden = false
                }
            }
            
//            Alamofire.request(.GET, "http://kangoobear.herokuapp.com/api/patients/\(userID))", headers:headers, encoding: encoding).validate(statusCode: 200..<300)
//                .responseJSON{(response) in
//                    
//                    print(response.request)  // original URL request
//                    print(response.response) // URL response
//                    print(response.data)     // server data
//                    print(response.result)   // result of response serialization
//                    print(response.request?.HTTPBody)
//                    
//                    if let JSONResponse = response.result.value {
//                        //                    print("JSON: \(JSONResponse)")
//                        
//                        if let dataFromString = JSONResponse.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
//                            let json = JSON(data: dataFromString)
//                            print(json)
//                            if json["err"] == nil {
//                                
//                            }
//                        }
//                    }
//                    
//                    print(response.result.value)
//            }
        } else {
            print("There's no userID in the defaults, thanks Jessica.")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}