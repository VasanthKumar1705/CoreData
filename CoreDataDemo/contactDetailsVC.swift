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
    var getDataTitles : [String] = []

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
  
    
    @IBAction func RegisterButtonTapped(_ sender: Any) {
        if (NametextField.hasText && emailTextfield.hasText && phoneTextfield.hasText){
            print("all fields are filled")
            createItem(name: NametextField.text ?? "no value", phone: phoneTextfield.text ?? "no value", email: emailTextfield.text ?? "no value")
            _ = navigationController?.popViewController(animated: true)
        }else{
            print("please fill the field")
            Toast.show(message: "please fill all the fields", controller: self)
        }
    }
        
    func createItem(name:String,phone:String,email:String){
        let newItem = User(context: context)
        newItem.name = name
        newItem.phone = phone
        newItem.email = email
        do{
            try context.save()
            
        }
        catch {
            print("error")
        }
    }
}
