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
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<User> = {
            let fetchRequest : NSFetchRequest =  User.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            let fetchedResultsContoller = NSFetchedResultsController.init(fetchRequest: fetchRequest, managedObjectContext:  context , sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsContoller.delegate = self
            return fetchedResultsContoller
      }()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.userDataTableView.delegate = self
        self.userDataTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getDetails()
        
    }
    override func viewDidAppear(_ animated: Bool) {
//        getAllItem()
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
//            getAllItem()
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
//            getAllItem()
        }
        catch {
            print("error")
        }
    }
}
extension ViewController : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sections = self.fetchedResultsController.sections!
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.userDataTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! customTableViewCell
        cell.nameLabel.text = fetchedResultsController.object(at: indexPath).name//MyData[indexPath.row].name
        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "profileVC") as? profileViewController
                let dta = fetchedResultsController.object(at: indexPath)//MyData[indexPath.row]
                vc?.username = (dta.value(forKey: "name") as! String)
                vc?.email = (dta.value(forKey: "email") as! String)
                vc?.phone = (dta.value(forKey: "phone") as! String)
                navigationController?.pushViewController(vc!, animated: true)
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        

        let dta = fetchedResultsController.object(at: indexPath)//self.MyData[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, handler) in
            print("Delete Action Tapped")
            self.deleteItem(item: dta)
//            tableView.deleteRows(at: [indexPath], with: .fade)
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
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
         if (self.fetchedResultsController.sections != nil){
            return (self.fetchedResultsController.sections?.count)!
            }
            return 0
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
           guard let sectionInfo = fetchedResultsController.sections?[section] else {
               return nil
           }
           return sectionInfo.name
    }
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return self.fetchedResultsController.section(forSectionIndexTitle: title, at: index)
    }
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
       return fetchedResultsController.sectionIndexTitles
    }
    
}

extension ViewController : NSFetchedResultsControllerDelegate{
    func getDetails()  {
            do {
                try self.fetchedResultsController.performFetch()
            } catch let error {
                print("Error",error)
            }
        }
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
           userDataTableView.beginUpdates()
       }
       
       func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
           switch type {
           case .delete:
               userDataTableView.deleteRows(at: [indexPath!], with: .fade )
           case.insert:
               userDataTableView.insertRows(at: [newIndexPath!] , with: .fade)
               let a = fetchedResultsController.object(at: newIndexPath!).name
           case .update:
                self.userDataTableView.reloadRows(at: [indexPath!], with: .fade)
           case .move:
               self.userDataTableView.deleteRows(at: [indexPath!], with: .fade)
               self.userDataTableView.insertRows(at: [newIndexPath!], with: .fade)
               break
           default:
               print("default")
           }
       }
       
       func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
           userDataTableView.endUpdates()
       }
}
