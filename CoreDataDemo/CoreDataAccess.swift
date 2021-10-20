//
//  CoreDataAccess.swift
//  CoreDataDemo
//
//  Created by vasanth on 20/10/21.
//

import Foundation
import CoreData
import UIKit

class CoreDataAccess {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    static let shared = CoreDataAccess()
    func deleteItem(item:User){
        context.delete(item)
        do{
            try context.save()
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
        }
        catch {
            print("error")
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
