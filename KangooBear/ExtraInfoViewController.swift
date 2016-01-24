//
//  ExtraInfoViewController.swift
//  KangooBear
//
//  Created by Eytan Schulman on 1/23/16.
//  Copyright © 2016 MultiEducator. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ExtraInfoViewController: UITableViewController,UITextFieldDelegate {

    var passedJSONString: String?
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var addressTextField: UITextField!
    @IBOutlet var cityTextField: UITextField!
    @IBOutlet var stateTextField: UITextField!
    @IBOutlet var zipTextField: UITextField!
    @IBOutlet var phoneNumberTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor(red: 224/250, green: 224/255, blue: 224/255, alpha: 224/255)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Continue", style: UIBarButtonItemStyle.Plain, target: self, action: "continueAction")
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: "secretButtonVerySecretMuchWowFillInInfo")
        
        setupChangeNotifications()
        // Do any additional setup after loading the view.
    }
    
    func setupChangeNotifications() {
        nameTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        addressTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        cityTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        stateTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        zipTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        phoneNumberTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    }
    
    func secretButtonVerySecretMuchWowFillInInfo() {
        self.nameTextField.text = "Bryan Hart"
        self.addressTextField.text = "1932 Annin St"
        self.cityTextField.text = "Philadelphia"
        self.stateTextField.text = "PA"
        self.zipTextField.text = "19146"
        self.phoneNumberTextField.text = "(215)-267-8394"
        
        if everythingFilledOut() {
            self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        }
    }
    
    func textFieldDidChange(textField: UITextField) {
        if everythingFilledOut() {
            self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        } else {
            self.navigationController?.navigationBar.tintColor = UIColor(red: 224/250, green: 224/255, blue: 224/255, alpha: 224/255)
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if everythingFilledOut() {
            self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        } else {
            self.navigationController?.navigationBar.tintColor = UIColor(red: 224/250, green: 224/255, blue: 224/255, alpha: 224/255)
        }
    }
    
//    func textFieldDidEndEditing(textField: UITextField) {
//        if everythingFilledOut() {
//            self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
//        } else {
//            self.navigationController?.navigationBar.tintColor = UIColor(red: 224/250, green: 224/255, blue: 224/255, alpha: 224/255)
//        }
//    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func allFieldsFilledOut() -> Bool {
        if nameTextField.text?.characters.count == 0 {
            return false
        } else if addressTextField.text?.characters.count == 0 {
            return false
        } else if cityTextField.text?.characters.count == 0 {
            return false
        } else if stateTextField.text?.characters.count == 0 {
            return false
        } else if zipTextField.text?.characters.count == 0 {
            return false
        } else if phoneNumberTextField.text?.characters.count == 0 {
            return false
        }
        
        return true
    }
    
    func everythingFilledOut() -> Bool {
        if nameTextField.text?.characters.count > 0 && addressTextField.text?.characters.count > 0 && cityTextField.text?.characters.count > 0 && stateTextField.text?.characters.count > 0 && zipTextField.text?.characters.count > 0 && phoneNumberTextField.text?.characters.count > 0 {
            return true
        }
        
        return false
    }
    
    func continueAction() {
        if allFieldsFilledOut() {
            if let pjsonString = passedJSONString {
                if let data = pjsonString.dataUsingEncoding(NSUTF8StringEncoding) {
                    let json = JSON(data: data)
                    var returnDict = [String : String]()
                    returnDict["access_token"] = json["access_token"].stringValue
                    returnDict["scope"] = json["scope"].stringValue
                    returnDict["subscription read"] = json["subscription read"].stringValue
                    returnDict["token_type"] = json["token_type"].stringValue
                    returnDict["name"] = nameTextField.text
                    returnDict["address"] = "\(addressTextField.text!), \(cityTextField.text!), \(stateTextField.text!), \(zipTextField.text!)"
                    
                    var modelData = [String: Dictionary<String,String>]()
                    modelData["modelData"] = returnDict
                    
                    sendRequest(modelData)
                }
            }//
        } else {
            let ac = UIAlertController(title: "You have not filled out all fields", message: nil, preferredStyle: .Alert)
            let action = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            ac.addAction(action)
            self.presentViewController(ac, animated: true, completion: nil)
        }
        
    }
    func sendRequest(parameters: [String: Dictionary<String,String>]) {
        
        let headers = ["Content-Type":"application/json"]
        
        let encoding = Alamofire.ParameterEncoding.JSON
        
        Alamofire.request(.POST, "http://kangoobear.herokuapp.com/api/patients",parameters: parameters, headers:headers, encoding: encoding).validate(statusCode: 200..<300)
            .responseJSON{(response) in
                
                print(response.request)  // original URL request
                print(response.response) // URL response
                print(response.data)     // server data
                print(response.result)   // result of response serialization
                print(response.request?.HTTPBody)
                
                if let JSONResponse = response.result.value {
                    print("JSON: \(JSONResponse)")
                    
//                    if let dataFromString = JSONResponse.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                        let json = JSON(JSONResponse)
                        if json["err"] == nil {
                        NSUserDefaults.standardUserDefaults().setObject(json["patient"]["_id"].stringValue, forKey: "userID")
                        self.performSegueWithIdentifier("MainVCSegue", sender: nil)
                        }
//                    }
                }
                
                print(response.result.value)
        }
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

class BBTextField: UITextField {
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 20, 0)
    }
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 20, 0)
    }
}