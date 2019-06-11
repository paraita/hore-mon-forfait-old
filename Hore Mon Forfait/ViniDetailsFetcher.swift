//
//  ViniDetailsFetcher.swift
//  Hore Mon Forfait
//
//  Created by Paraita Wohler on 14/11/2018.
//  Copyright © 2018 Paraita. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireObjectMapper

class ViniDetailsFetcher {
    
    init() {}
    
    func fetchConso(completion: @escaping (Conso?) -> Void) -> Void {
        if credentialsExist() {
            let credentials = UserDefaults(suiteName: .horeCacheSuiteName)!
            guard let url = URL(string: "https://apps.vini.pf/SLFCR/APPS")
                else {
                    print("oops error creating the URL")
                    return
            }
            let parameters = ["content": "conso",
                              "msisdn": credentials.string(forKey: .horeCredentialsMsisdn)!,
                              "password": credentials.string(forKey: .horeCredentialsPassword)!]
            let headers: HTTPHeaders
            headers = ["content-type": "application/x-www-form-urlencoded"]
            AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).validate().responseObject {
                (response: DataResponse<Conso>) in
                if let conso = response.result.value {
                    self.debug(conso)
                    completion(conso)
                }
                else {
                    print("Error during the fetching of the conso")
                }
            }
        }
        else {
            print("Cancelling the fetching, no credentials found !")
        }
    }
    
    fileprivate func credentialsExist() -> Bool {
        let credentials = UserDefaults(suiteName: .horeCacheSuiteName)!
        return credentials.string(forKey: .horeCredentialsMsisdn) != nil &&
            credentials.string(forKey: .horeCredentialsPassword) != nil
    }
    
    fileprivate func debug(_ conso: Conso?) {
        print("fetched conso:")
        print(" consumed=\(conso!.consumed!)")
        print(" remaining=\(conso!.remaining!)")
        print(" monthlyAmount=\(conso!.monthlyAmount!)")
    }
}
