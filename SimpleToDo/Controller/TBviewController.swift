//
//  ViewController.swift
//  SimpleToDo
//
//  Created by Alex Busol on 7/4/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit
import RealmSwift

class TBviewController: UITableViewController { //change the subclass to uitableViewController to link it to the table viewC in the mainStoryboard.

    var itemArray : Results<Item>? //collection of results
    let realm = try! Realm()
    
    var selectedCategory : Category? {
        didSet{ //going to happen as soon as the category item gets set with value
            loadData() //loads all of our items when the app is called
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }

    
    
    
    
    //MARK: - Create TableView Data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int ) -> Int {
        return itemArray?.count ?? 1 //will create as many cells in the table view as there are cells in the itemArray
    }
    
    
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        if let tempItem = itemArray?[indexPath.row] {
        
        cell.textLabel?.text = tempItem.title
        
        if tempItem.isDone == true {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        } else {
            cell.textLabel?.text = "No Items Added Yet :("
        }
       
        return cell
    }
    
    //MARK: - Create table view delegate methods. ADD CHECKMARKS ON CLICKED ITEMS. ANIMATE THE SELECTED ROW
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        if let item = itemArray?[indexPath.row] {
            do {
                try realm.write {
                    item.isDone = !item.isDone
                }
            } catch {
                print("error saving checkmark")
            }
            
        }
        
        tableView.reloadData()
       
        tableView.deselectRow(at: indexPath, animated: true) //makes the cells flash gray and then go back to white after being clicked.
       
    }
    
    /* !!! --no longer used. will update this method later
    
    //MARK: ----------------------enabling SLIDE TO DELETE------------------------
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
        
          //  context.delete(itemArray[indexPath.row]) //order matters. call this first before removing the item form the array.
            itemArray.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // saveData() - not needed because deleteRows already reorders the tableView

        }
    }
    */
    
    
    //MARK - create add new items functionality
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let textAlert = UIAlertController(title: "Add a new toDo item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            print("success")
            
            //------------------ CREATING AND INITIALISING A NEW TODO ITEM --------------------
            
            
            //we are going to do all saving here as well
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date() //writing the current date
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error unwrapping selected category")
                }
                
            }
            
            self.tableView.reloadData() //update the changes
         
            
        }
        
    
        //the alert will have a text field that the user can fill
        textAlert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField //will hold the text that user has entered
        }
            
            textAlert.addAction(action)
            present(textAlert, animated:true, completion: nil)
            
        }
    
    func loadData() {
        itemArray = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

        tableView.reloadData()

    }

    
    
}


//----------------------------- ENABLING SEARCH BAR FUNCTIONALITY ----------------------------


extension TBviewController: UISearchBarDelegate { //can extend the class's functionality this wayinstead of adding the delegate directly to the class


    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            itemArray = itemArray?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()

    }

    //when the text changed and went down to 0
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadData()

            DispatchQueue.main.async { //select the main thread of exectuion. forces the code inside to run in the foreground.
                searchBar.resignFirstResponder() //deselects the search bar and dismisses the keyboard.
            }

        }
    }
}
