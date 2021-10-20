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
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<User> = {
            let fetchRequest : NSFetchRequest =  User.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let fetchedResultsContoller = NSFetchedResultsController.init(fetchRequest: fetchRequest, managedObjectContext:  CoreDataAccess.shared.context , sectionNameKeyPath: "name", cacheName: nil)
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
        self.getAllItems()
    }
    @IBAction func AddButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "go", sender: nil)
    }

    func getAllItems()  {
            do {
                try self.fetchedResultsController.performFetch()
               
            } catch let error {
                print("Error",error)
            }
    }
}
extension ViewController : UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = self.fetchedResultsController.sections else { return 0 }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.userDataTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? customTableViewCell else {
            fatalError("Unexpected indexpath!!")
        }
        cell.nameLabel.text = fetchedResultsController.object(at: indexPath).name
        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "profileVC") as? profileViewController {
            let dta = fetchedResultsController.object(at: indexPath)
            vc.username = (dta.value(forKey: "name") as! String)
            vc.email = (dta.value(forKey: "email") as! String)
            vc.phone = (dta.value(forKey: "phone") as! String)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let dta = fetchedResultsController.object(at: indexPath)
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, handler) in
            print("Delete Action Tapped")
            CoreDataAccess.shared.deleteItem(item: dta)
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

                CoreDataAccess.shared.UpdateTime(item: dta, newName: nameTextField.text ?? "", newPhone: phoneTextField.text ?? "", newEmail: emailTextField.text ?? "")
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

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
           guard let sectionInfo = fetchedResultsController.sections?[section] else {
               return nil
           }
        return sectionInfo.indexTitle
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return self.fetchedResultsController.section(forSectionIndexTitle: title, at: index)
    }
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
       return fetchedResultsController.sectionIndexTitles
    }
    
}

extension ViewController : NSFetchedResultsControllerDelegate{

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.userDataTableView.beginUpdates()
    }
       
       func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
           guard let indexPath = indexPath else { return }
           guard let newIndexPath = newIndexPath else { return }
           switch type {
           case .delete:
               self.userDataTableView.deleteRows(at: [indexPath], with: .fade )
           case.insert:
               self.userDataTableView.insertRows(at: [newIndexPath] , with: .fade)
           case .update:
               self.userDataTableView.reloadRows(at: [indexPath], with: .fade)
           case .move:
               self.userDataTableView.deleteRows(at: [indexPath], with: .fade)
               self.userDataTableView.insertRows(at: [newIndexPath], with: .fade)
               break
           default:
               print("default")
           }
       }
       
       func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
           self.userDataTableView.endUpdates()
       }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,didChange sectionInfo: NSFetchedResultsSectionInfo,atSectionIndex sectionIndex: Int,for type: NSFetchedResultsChangeType) {
        let section = IndexSet(integer: sectionIndex)
        switch type {
            case .delete:
                  self.userDataTableView.deleteSections(section, with: .automatic)
            case .insert:
                  self.userDataTableView.insertSections(section, with: .automatic)
        default:
            print("default")
        }
    }
}
