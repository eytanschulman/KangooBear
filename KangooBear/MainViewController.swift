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
        
        loadDataFromDefaults()
        
        sendRequest()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: "removeUserDefaults")
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: self, action: "sendPush")
    }
    
    
    
    func removeUserDefaults() {
//        NSDictionary *defaultsDictionary = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
//        for (NSString *key in [defaultsDictionary allKeys]) {
//            [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
//        }
        
        let defaultsDict = NSUserDefaults.standardUserDefaults().dictionaryRepresentation()
        for key in defaultsDict.keys {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(key)
        }
    }
    
    func loadDataFromDefaults() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        self.dosageLevelLabel.text = userDefaults.objectForKey("dosage") as? String
        self.costLabel.text = userDefaults.objectForKey("cost") as? String
        self.deliveryTimeLabel.text = userDefaults.objectForKey("deliveryTime") as? String
        self.addressLabel.text = userDefaults.objectForKey("") as? String
    }
    
    @IBAction func performRequest() {

    }
    
    func sendPush() {
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSinceNow: 5)
        notification.alertBody = "Your doctor has prescribed you a new dosage of insulin"
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
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
                
                self.dosageLevelLabel.text = json["patients"]["dosage"].stringValue
                self.costLabel.text = json["patients"]["cost"].stringValue
                self.deliveryTimeLabel.text = json["patients"]["deliveryTime"].stringValue
                self.addressLabel.text = json["patients"]["address"].stringValue
                
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
