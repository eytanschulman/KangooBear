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
    @IBOutlet var requestDelivery: UIButton!
    
    var timer: NSTimer!
    var dosage = ""
    var json: JSON!
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        loadDataFromDefaults()
        
        sendRequest()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: "removeUserDefaults")
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: self, action: "sendPush")
        
        NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "requestPeriodically", userInfo: nil, repeats: true)
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
    
    func requestPeriodically() {
        sendRequest()
    }
    
    func loadDataFromDefaults() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        self.dosageLevelLabel.text = userDefaults.objectForKey("dosage") as? String
        self.costLabel.text = userDefaults.objectForKey("cost") as? String
        self.deliveryTimeLabel.text = userDefaults.objectForKey("deliveryTime") as? String
        self.addressLabel.text = userDefaults.objectForKey("address") as? String
    }
    
    @IBAction func performRequest() {
        //is code going here?
        sendPostmatesRequest()
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
                if let pd = patientData {
                    json = JSON(data: pd)
                    
                    let userDefaults = NSUserDefaults.standardUserDefaults()
                    
                    if json["patient"]["dosage"].stringValue != userDefaults.objectForKey("dosage") as? String {
                        self.noPrescriptionView.hidden = true
                        self.hasPrescriptionView.hidden = false
                        //has prescription
                        self.requestDelivery.hidden = false
                    } else {
                        self.noPrescriptionView.hidden = false
                        self.hasPrescriptionView.hidden = true
                        self.requestDelivery.hidden = true
                    }
                    
                    self.dosageLevelLabel.text = json["patient"]["dosage"].stringValue
                    self.costLabel.text = "$\(json["postmates"]["fee"].numberValue.integerValue/100)"
                    self.deliveryTimeLabel.text = "\(json["postmates"]["duration"].stringValue) Minutes"
                    
                    self.addressLabel.text = json["patient"]["address"].stringValue
                    
                    print(json)
                    
//                    if !dosageRequestedExists(json["patient"]["dosage"].stringValue) {
//                        if Int(json["patient"]["dosage"].stringValue.stringByReplacingOccurrencesOfString("IU", withString: "")) == 100 {
//                            //NO PRESCRIPTIONS
//                            self.noPrescriptionView.hidden = false
//                            self.hasPrescriptionView.hidden = true
//                        } else {
//                            //HAS PRESCRIPTIONS
//                            self.noPrescriptionView.hidden = true
//                            self.hasPrescriptionView.hidden = false
//                        }
//                    }
                    
                }
            }
        } else {
            print("There's no userID in the defaults, thanks Jessica.")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func sendPostmatesRequest() {
        let headers = ["Content-Type":"application/json"]
        
        let encoding = Alamofire.ParameterEncoding.JSON
        
        if let userID = NSUserDefaults.standardUserDefaults().objectForKey("userID") as? String! {
            
            Alamofire.request(.POST, "http://kangoobear.herokuapp.com/api/patients/\(userID))", headers:headers, encoding: encoding).validate(statusCode: 200..<300)
                .responseJSON{(response) in
                    
                    print(response.request)  // original URL request
                    print(response.response) // URL response
                    print(response.data)     // server data
                    print(response.result)   // result of response serialization
                    print(response.request?.HTTPBody)
                    
                    let userDefaults = NSUserDefaults.standardUserDefaults()
                    userDefaults.setObject(self.json["patient"]["dosage"].stringValue, forKey: "dosage")
                    userDefaults.setObject("$\(self.json["postmates"]["fee"].numberValue.integerValue/100)", forKey: "cost")
                    userDefaults.setObject("\(self.json["postmates"]["duration"].stringValue) Minutes", forKey: "deliveryTime")
                    userDefaults.setObject(self.json["patient"]["address"].stringValue, forKey: "address")
                    
                    self.performSegueWithIdentifier("ShipmentVC", sender: nil)
                    
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
                    
                    print(response.result.value)
            }

        }
    }
    
    @IBAction func getBackToPrescriptionVC(segue: UIStoryboardSegue) {
        
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
