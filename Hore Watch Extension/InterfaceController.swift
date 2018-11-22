//
//  InterfaceController.swift
//  Hore Watch Extension
//
//  Created by Paraita Wohler on 14/11/2018.
//  Copyright © 2018 Paraita. All rights reserved.
//

import WatchKit
import Foundation
import Alamofire
import AlamofireObjectMapper
import WatchConnectivity

struct coldCacheKey {
    static let CONSUMED = "lastConsumed"
    static let REMAINING = "lastRemaining"
    static let CONSUMED_PCT = "lastConsumedPct"
    static let TOTAL = "lastTotal"
}

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet var remainingValue: WKInterfaceLabel!
    @IBOutlet var consumedValue: WKInterfaceLabel!
    @IBOutlet var consumedPct: WKInterfaceLabel!
    @IBOutlet var totalValue: WKInterfaceLabel!
    let viniDetailsFetcher: ViniDetailsFetcher = ViniDetailsFetcher()
    var conso: Conso?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let watchSession = WCSession.default
        watchSession.delegate = self
        watchSession.activate()
        
        // fill the UI with either the previous data or leave the fields empty
        loadColdValues()
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        fetchConso()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        cacheConsoData(nil)
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("session activated from watch !")
        fetchConso()
        loadColdValues()
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("Just received data from the iPhone")
        print("\(applicationContext)")
        cacheCredentials(msisdn: applicationContext["phoneNumber"] as! String, password: applicationContext["password"] as! String)
        fetchConso()
        cacheConsoData(nil)
    }
    
    
    fileprivate func fetchConso() {
        self.viniDetailsFetcher.fetchConso {conso in
            if conso != nil {
                let newConsumed = Double(conso?.consumed! ?? -1)
                let newRemaining = Double(conso?.remaining! ?? -1)
                let newTotal = Double(conso?.monthlyAmount! ?? -1)
                let newConsumedPct = newConsumed / newTotal
                
                self.remainingValue.setText(String(newRemaining) + "Mb")
                self.consumedValue.setText(String(newConsumed) + "Mb")
                self.consumedPct.setText(String(format: "%.2f", newConsumedPct * 100) + "%")
                self.totalValue.setText(String(newTotal) + "Mb")
                self.conso = conso
                self.cacheConsoData(conso)
            }
        }
    }
    
    fileprivate func cacheCredentials(msisdn: String, password: String) {
        let userDefaults = UserDefaults(suiteName: "group.hipopochat.hore.mon.forfait")!
        userDefaults.set(msisdn, forKey: "phoneNumber")
        userDefaults.set(password, forKey: "password")
        print("saved \(msisdn)/\(password)")
    }
    
    fileprivate func cacheConsoData(_ conso: Conso?) {
        print("caching the conso")
        let userDefaults = UserDefaults(suiteName: "group.hipopochat.hore.mon.forfait")!
        
        if let toSave = conso {
            let consumedPct = Double(toSave.consumed!) / Double(toSave.monthlyAmount!)
            userDefaults.set(toSave.consumed, forKey: coldCacheKey.CONSUMED)
            userDefaults.set(toSave.remaining, forKey: coldCacheKey.REMAINING)
            userDefaults.set(toSave.monthlyAmount, forKey: coldCacheKey.TOTAL)
            userDefaults.set(consumedPct, forKey: coldCacheKey.CONSUMED_PCT)
        }
        else if let toSave = self.conso {
            let consumedPct = Double(toSave.consumed!) / Double(toSave.monthlyAmount!)
            userDefaults.set(toSave.consumed, forKey: coldCacheKey.CONSUMED)
            userDefaults.set(toSave.remaining, forKey: coldCacheKey.REMAINING)
            userDefaults.set(toSave.monthlyAmount, forKey: coldCacheKey.TOTAL)
            userDefaults.set(consumedPct, forKey: coldCacheKey.CONSUMED_PCT)
        }
    }
    
    fileprivate func loadColdValues() {
        print("Reading from the cache...")
        let userDefaults = UserDefaults(suiteName: "group.hipopochat.hore.mon.forfait")!
        if let lastRemaining = userDefaults.string(forKey: coldCacheKey.REMAINING) {
            self.remainingValue.setText(lastRemaining + "Mb")
        }
        else {
            self.remainingValue.setText("NOPE")
        }
        if let lastConsumed = userDefaults.string(forKey: coldCacheKey.CONSUMED) {
            self.consumedValue.setText(lastConsumed + "Mb")
        }
        else {
            self.consumedValue.setText("NOPE")
        }
        if let lastConsumedPct = userDefaults.string(forKey: coldCacheKey.CONSUMED_PCT) {
            self.consumedPct.setText(String(format: "%.2f", Double(lastConsumedPct)! * 100.0) + "%")
        }
        else {
            self.consumedPct.setText("NOPE")
        }
        if let lastTotal = userDefaults.string(forKey: coldCacheKey.TOTAL) {
            self.totalValue.setText(lastTotal + "Mb")
        }
        else {
            self.totalValue.setText("NOPE")
        }
    }
    
}
