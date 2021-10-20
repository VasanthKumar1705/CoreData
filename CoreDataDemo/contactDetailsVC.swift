//
//  contactDetailsVC.swift
//  CoreDataDemo
//
//  Created by vasanth on 13/10/21.
//

import UIKit
import CoreData



class contactDetailsVC: UIViewController {

    @IBOutlet var RegisterButton: UIButton!
    @IBOutlet weak var phoneTextfield: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var NametextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
  
    
    @IBAction func RegisterButtonTapped(_ sender: Any) {
        if (NametextField.hasText && emailTextfield.hasText && phoneTextfield.hasText){
            print("all fields are filled")
            CoreDataAccess.shared.createItem(name: NametextField.text ?? "", phone: phoneTextfield.text ?? "", email: emailTextfield.text ?? "")
            _ = navigationController?.popViewController(animated: true)
        }else{
            print("please fill the field")
            Toast.show(message: "please fill all the fields", controller: self)
        }
    }
        
}
