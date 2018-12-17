//
//  TodayViewController.swift
//  Hore Mon Forfait Widget
//
//  Created by Paraita Wohler on 13/11/2018.
//  Copyright © 2018 Paraita. All rights reserved.
//

import UIKit
import NotificationCenter
import Alamofire
import AlamofireObjectMapper

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet var consoPercent: UILabel!
    @IBOutlet var consumedValue: UILabel!
    @IBOutlet var remainingValue: UILabel!
    @IBOutlet var totalValue: UILabel!
    @IBOutlet var progressBar: UIProgressView!
    
    let viniDetailsFetcher: ViniDetailsFetcher = ViniDetailsFetcher()
    let cache = UserDefaults(suiteName: .horeCacheSuiteName)!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        if cacheExist() {
            loadFromCache()
        }
        else {
            consoPercent.text = "loading.."
            consumedValue.text = "loading.."
            remainingValue.text = "loading.."
            totalValue.text = "loading.."
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        
        self.viniDetailsFetcher.fetchConso {conso in
            
            let newConsumed = Double(conso?.consumed! ?? -1)
            let newRemaining = Double(conso?.remaining! ?? -1)
            let newTotal = Double(conso?.monthlyAmount! ?? -1)
            let newConsumedPct = newConsumed / newTotal
            
            self.consumedValue.text = String(newConsumed) + "Mb"
            self.remainingValue.text = String(newRemaining) + "Mb"
            self.totalValue.text = String(newTotal) + "Mb"
            self.consoPercent.text = String(format: "%.2f", newConsumedPct * 100) + "%"
            self.progressBar.progress = Float(newConsumedPct)
            
            self.saveToCache(conso!)
            
            completionHandler(NCUpdateResult.newData)
        }
    }
    
    fileprivate func cacheExist() -> Bool {
        return cache.string(forKey: .horeCacheLastConsumed) != nil
            && cache.string(forKey: .horeCacheLastConsumedPct) != nil
            && cache.string(forKey: .horeCacheLastRemaining) != nil
            && cache.string(forKey: .horeCacheLastTotal) != nil
    }
    
    // We assume the data exist in the cache
    fileprivate func loadFromCache() {
        consumedValue.text = "\(cache.double(forKey: .horeCacheLastConsumed))Mb"
        remainingValue.text = "\(cache.double(forKey: .horeCacheLastRemaining))Mb"
        totalValue.text = "\(cache.double(forKey: .horeCacheLastTotal))Mb"
        consoPercent.text = "\(String(format: "%.2f", cache.double(forKey: .horeCacheLastConsumedPct) * 100.0))%"
        progressBar.progress = cache.float(forKey: .horeCacheLastConsumedPct)
    }
    
    fileprivate func saveToCache(_ conso: Conso) {
        let consumedPct = Float(conso.consumed!) / Float(conso.monthlyAmount!)
        cache.set(conso.consumed, forKey: .horeCacheLastConsumed)
        cache.set(conso.remaining, forKey: .horeCacheLastRemaining)
        cache.set(conso.monthlyAmount, forKey: .horeCacheLastTotal)
        cache.set(consumedPct, forKey: .horeCacheLastConsumedPct)
    }
    
}
