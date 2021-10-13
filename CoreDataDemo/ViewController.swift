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
    var getData : [NSManagedObject] = []
    var userNameData = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.userDataTableView.delegate = self
        self.userDataTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchRecord()
    }
    @IBAction func AddButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "go", sender: nil)
    }
    func getContext() -> NSManagedObjectContext{
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        return managedContext
    }
    func fetchRecord(){
        getData = []
        userNameData = []
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.returnsObjectsAsFaults = false
        do {
             let result = try self.getContext().fetch(request)
             for data in result as! [NSManagedObject] {
                 
              getData.append(data)
              userNameData.append(data.value(forKey: "name") as! String)
             }
        } catch let error as NSError{
            print("Could not fetch ,\(error),\(error.userInfo)")
        }
        
        self.userDataTableView.reloadData()
        print("fetch data-->" ,getData)
    }
    

}

extension ViewController : UITableViewDataSource,UITableViewDelegate{
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.userDataTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! customTableViewCell
        let dta = getData[indexPath.row]
        cell.nameLabel.text = dta.value(forKey: "name") as? String
        return cell
    }
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "profileVC") as? profileViewController
        let dta = self.getData[indexPath.row]
        vc?.username = (dta.value(forKey: "name") as! String)
        vc?.email = (dta.value(forKey: "email") as! String)
        vc?.phone = (dta.value(forKey: "phone") as! String)
        navigationController?.pushViewController(vc!, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
        func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let dta = self.getData[indexPath.row]
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, handler) in
                print("Delete Action Tapped")
                self.getContext().delete(dta)
                self.getData.remove(at: indexPath.row)
                do {
                    try self.getContext().save()
                } catch let error as NSError {
                    print("Could not save. \(error),\(error.userInfo)")
                }
                tableView.deleteRows(at: [indexPath], with: .fade)
                print("after delete-->",self.getData)
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
    
                    dta.setValue(nameTextField.text, forKey: "name")
                    dta.setValue(emailTextField.text, forKey: "email")
                    dta.setValue(phoneTextField.text, forKey: "phone")
    
                    do {
                        try self.getContext().save()
                        print("record Updated successfully!!")
                    }catch let error as NSError{
                        print("Could not save ,\(error),\(error.userInfo)")
                    }
                    self.userDataTableView.reloadData()
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
