//
//  AccountDetails.swift
//  Hore Mon Forfait
//
//  Created by Paraita Wohler on 13/11/2018.
//  Copyright © 2018 Paraita. All rights reserved.
//

import Foundation
import ObjectMapper

class Conso: Mappable {
    
    var consumed: Int?
    var remaining: Int?
    var monthlyAmount: Int?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        consumed <- map["detail_forfait.internet_mobile_premium.consumed_mo"]
        remaining <- map["detail_forfait.internet_mobile_premium.remaining_mo"]
        monthlyAmount <- map["detail_forfait.internet_mobile_premium.credits_mo"]
    }
    
    
}
