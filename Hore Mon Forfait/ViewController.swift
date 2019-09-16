//
//  ViewController.swift
//  Hore Mon Forfait
//
//  Created by Paraita Wohler on 13/11/2018.
//  Copyright © 2018 Paraita. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import WatchConnectivity
import os

class ViewController: UIViewController, WCSessionDelegate, UITextFieldDelegate {
    
    @IBOutlet var phoneNumber: UITextField!
    @IBOutlet var password: UITextField!
    
    let viniDetailsFetcher: ViniDetailsFetcher = ViniDetailsFetcher()
    var credentials: UserDefaults?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.credentials = UserDefaults(suiteName: .horeCacheSuiteName)
        phoneNumber.text = self.credentials!.string(forKey: .horeCredentialsMsisdn)
        password.text = self.credentials!.string(forKey: .horeCredentialsPassword)
        
        self.password.delegate = self
        
        
        self.setPhoneNumberKeyboard()
    }

    @IBAction func saveCredentials(_ sender: Any) {
        if phoneNumber.hasText && password.hasText {
            os_log("PhoneNumber and password filled ! saving...")
            self.credentials!.set(phoneNumber.text, forKey: .horeCredentialsMsisdn)
            self.credentials!.set(password.text, forKey: .horeCredentialsPassword)
            os_log("saved credentials !")
            self.sendStuffToTheWatch()
        }
        else {
            os_log("Didn't save anything because the phoneNumber or the password is missing")
        }
    }
    
    @IBAction func fetchAccountDetails(_ sender: Any) {
        self.viniDetailsFetcher.fetchConso {conso in
            let newConsumed = Double(conso?.consumed! ?? -1)
            let newTotal = Double(conso?.monthlyAmount! ?? -1)
            let newConsumedPct = newConsumed / newTotal
            let consumedPctMsg = "Consumed " + String(format: "%.2f", newConsumedPct * 100.0) + "%"
            let alertController = UIAlertController(title: "Conso",
                                                    message: consumedPctMsg,
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Close", style: .default))
            self.present(alertController, animated: true, completion:nil)
        }
    }
    
    fileprivate func setPhoneNumberKeyboard() {
        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(ViewController.doneButtonAction))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        self.phoneNumber.keyboardType = .phonePad
        self.phoneNumber.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonAction() {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func sendStuffToTheWatch() {
        print("Sending data to the watch...")
        if WCSession.isSupported() {
            let watchSession = WCSession.default
            watchSession.delegate = self
            watchSession.activate()
            DispatchQueue.main.async {
                if watchSession.isPaired && watchSession.isWatchAppInstalled {
                    if self.phoneNumber.text != nil && self.password.text != nil {
                        do {
                            try watchSession.updateApplicationContext(
                                ["phoneNumber": self.phoneNumber.text!,
                                 "password": self.password.text!,
                                 "date": Date()]
                            )
                        } catch let error as NSError {
                            os_log("error while fetching data from Vini: %@", type: .error, error.description)
                        }
                    }
                    else {
                        os_log("cancelled (no msisdn/password to send)")
                    }
                }
                else {
                    os_log("cancelled (no paired watch session)")
                }
            }
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        os_log("session opened !")
        self.sendStuffToTheWatch()
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        os_log("session became inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        os_log("session is deactivated")
    }
}

