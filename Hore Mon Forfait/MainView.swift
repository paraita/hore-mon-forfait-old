//
//  MainView.swift
//  Hore Mon Forfait
//
//  Created by Paraita Wohler on 10/3/19.
//  Copyright © 2019 Paraita. All rights reserved.
//

import Foundation
import UIKit

class MainView: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let imageView: UIImageView = UIImageView()
    let headerHeight: Int = 100
    let cellIdentifier: String = "maCellIdentifieur"
    
    let formFields = ["Restant", "Forfait", "Etat au", "N° de tél"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: CGFloat(headerHeight), left: 0, bottom: 0, right: 0)
        imageView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.size.width), height: headerHeight)
        imageView.image = UIImage.init(named: "ViniHeader")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        view.addSubview(imageView)
    }
    
}

extension MainView: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formFields.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell.init(style: UITableViewCell.CellStyle.value1, reuseIdentifier: cellIdentifier)
        cell.detailTextLabel!.text = "Tata"
        cell.textLabel!.text = formFields[indexPath.row]
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
     let y = CGFloat(headerHeight) - (scrollView.contentOffset.y + CGFloat(headerHeight))
        let height = min(max(y, 60), 400)
        imageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: height)
    }
    
}
