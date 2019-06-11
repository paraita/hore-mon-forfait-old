//
//  ComplicationController.swift
//  Hore Watch Extension
//
//  Created by Paraita Wohler on 14/11/2018.
//  Copyright © 2018 Paraita. All rights reserved.
//

import ClockKit
import Alamofire
import AlamofireObjectMapper

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    let viniDetailsFetcher: ViniDetailsFetcher = ViniDetailsFetcher()
    let userDefaults: UserDefaults = UserDefaults(suiteName: "group.hipopochat.hore.mon.forfait")!
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.forward, .backward])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        print("toto")
        if complication.family == .graphicCircular {
            print("getCurrentTimelineEntry")
            let template = CLKComplicationTemplateGraphicCircularClosedGaugeText()
            template.centerTextProvider = CLKSimpleTextProvider(text: "4G")

            self.viniDetailsFetcher.fetchConso {conso in
                
                if conso != nil {
                    let newConsumed = Float(conso?.consumed! ?? -1)
                    let newTotal = Float(conso?.monthlyAmount! ?? -1)
                    let newConsumedPct = newConsumed / newTotal
                    
                    let gauge = CLKSimpleGaugeProvider.init(style: .ring, gaugeColor: .red, fillFraction: 1.0 - newConsumedPct)
                    template.gaugeProvider = gauge
                    print("newConsumed: \(newConsumed)")
                    print("newTotal: \(newTotal)")
                    print("Just updated complication: \(newConsumedPct)")
                    handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
                }
                else {
                    handler(nil)
                }
            }
        }
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        
        if complication.family == .graphicCircular {
            print("getLocalizableSampleTemplate")
            let template = CLKComplicationTemplateGraphicCircularClosedGaugeText()
            if let lastConsumedPct = userDefaults.string(forKey: "lastConsumedPct") {
                print("Using \(lastConsumedPct) value for the complication !")
                let gauge = CLKSimpleGaugeProvider.init(style: .ring, gaugeColor: .red, fillFraction: 1.0 - Float(lastConsumedPct)!)
                template.gaugeProvider = gauge
            }
            else {
                print("No cached value found for the complication...")
                let gauge = CLKSimpleGaugeProvider.init(style: .ring, gaugeColor: .red, fillFraction: 1.0)
                template.gaugeProvider = gauge
            }
            template.centerTextProvider = CLKSimpleTextProvider(text: "4G")
            handler(template)
        }
        else {
            handler(nil)
        }
    }
    
}
