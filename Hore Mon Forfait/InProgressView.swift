//
//  InProgressView.swift
//  Hore Mon Forfait
//
//  Created by Paraita Wohler on 10/4/19.
//  Copyright © 2019 Paraita. All rights reserved.
//

import Foundation
import UIKit

class InProgressView: UIViewController {
    
    var spinner: UIActivityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.7)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)
        
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
}
