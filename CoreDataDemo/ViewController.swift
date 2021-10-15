//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by vasanth on 13/10/21.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet var userDataTableView: UITableView!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var MyData = [User]()
    var getDataTitles : [String] = []
    var getDataDictionary = [String : [String]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.userDataTableView.delegate = self
        self.userDataTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getAllItem()
    }
    @IBAction func AddButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "go", sender: nil)
    }

    // coreData
    func getAllItem(){
        do {
             MyData = try context.fetch(User.fetchRequest())
             DispatchQueue.main.async {
                self.userDataTableView.reloadData()
             }
        }
        catch {
            print("error")
        }
    }
    
    func deleteItem(item:User){
        context.delete(item)
        do{
            try context.save()
            getAllItem()
        }
        catch {
            print("error")
        }
    }
    
    func UpdateTime(item:User,newName:String,newPhone:String,newEmail:String){
        item.name = newName
        item.phone = newPhone
        item.email = newEmail
        do{
            try context.save()
            getAllItem()
        }
        catch {
            print("error")
        }
    }
}
extension ViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MyData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.userDataTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! customTableViewCell
        cell.nameLabel.text = MyData[indexPath.row].name
        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "profileVC") as? profileViewController
                let dta = MyData[indexPath.row]
                vc?.username = (dta.value(forKey: "name") as! String)
                vc?.email = (dta.value(forKey: "email") as! String)
                vc?.phone = (dta.value(forKey: "phone") as! String)
                navigationController?.pushViewController(vc!, animated: true)
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        

        let dta = self.MyData[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, handler) in
            print("Delete Action Tapped")
            self.deleteItem(item: dta)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        deleteAction.backgroundColor = .red
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, handler) in
            print("Edit Action Tapped")
            let alertController = UIAlertController(title: "Update Details", message: "", preferredStyle: .alert)

            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Enter Name"
                textField.text = dta.value(forKey: "name") as? String
            }
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Enter Email"
                textField.text = dta.value(forKey: "email") as? String
            }
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Enter Phone"
                textField.text = dta.value(forKey: "phone") as? String
            }

            let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
                let nameTextField = alertController.textFields![0] as UITextField
                let emailTextField = alertController.textFields![1] as UITextField
                let phoneTextField = alertController.textFields![2] as UITextField

                self.UpdateTime(item: dta, newName: nameTextField.text ?? "", newPhone: phoneTextField.text ?? "", newEmail: emailTextField.text ?? "")
                Toast.show(message: "Record update succesfully", controller: self)
            })

            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil )

            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)

            self.present(alertController, animated: true, completion: nil)
        }
        editAction.backgroundColor = .systemGray3
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction ,editAction])
        return configuration
    }
}
