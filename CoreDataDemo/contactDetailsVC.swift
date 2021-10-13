//
//  contactDetailsVC.swift
//  CoreDataDemo
//
//  Created by vasanth on 13/10/21.
//

import UIKit
import CoreData

class contactDetailsVC: UIViewController {

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
            self.createRecord()
            _ = navigationController?.popViewController(animated: true)
        }else{
            print("please fill the field")
            Toast.show(message: "please fill all the fields", controller: self)
        }
    }
    
    func getContext() -> NSManagedObjectContext{
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        return managedContext
    }
    
    func createRecord(){
        guard let userEntity = NSEntityDescription.entity(forEntityName: "User", in: self.getContext()) else { return }
        let user = NSManagedObject(entity: userEntity, insertInto: self.getContext())
        user.setValue(NametextField.text, forKey: "name")
        user.setValue(emailTextfield.text, forKey: "email")
        user.setValue(phoneTextfield.text, forKey: "phone")
        do {
            try self.getContext().save()
            print("record saved successfully!!")
        }catch let error as NSError{
            print("Could not save ,\(error),\(error.userInfo)")
        }
    }
    
    
}
