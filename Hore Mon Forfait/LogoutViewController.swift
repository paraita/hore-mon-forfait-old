//
//  LogoutViewController.swift
//  Hore Mon Forfait
//
//  Created by Paraita Wohler on 10/1/19.
//  Copyright © 2019 Paraita. All rights reserved.
//

import Foundation
import UIKit
import os

class LogoutViewController: UIViewController {
    
    
    @IBOutlet weak var telephoneNumber: UILabel!
    
    
    @IBSegueAction func logoutAction(_ coder: NSCoder) -> UIViewController? {
        return LoginViewController.init(coder: coder)
    }
    
}
