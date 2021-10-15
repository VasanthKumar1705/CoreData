//
//  profileViewController.swift
//  CoreDataDemo
//
//  Created by vasanth on 13/10/21.
//

import UIKit
import CoreData


class profileViewController: UIViewController {

    @IBOutlet var phonelabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    
    var username :String!
    var email : String!
    var phone : String!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        phonelabel.text = phone
        emailLabel.text = email
        usernameLabel.text = username
    }
}
