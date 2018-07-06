//
//  ViewController.swift
//  SimpleToDo
//
//  Created by Alex Busol on 7/4/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TBviewController: SwipeTableViewController { //change the subclass to uitableViewController to link it to the table viewC in the mainStoryboard.
    
    //MARK: - declaring required global variables
    
    var itemArray : Results<Item>? //collection of results
    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    var selectedCategory : Category? {
        didSet{ //going to happen as soon as the category item gets set with value
            loadData() //loads all of our items when the app is called
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
    }

    override func viewWillAppear(_ animated: Bool) { //gets called right before the view controller appears on the screen
        
        if let color = selectedCategory?.categoryColor {
            title = selectedCategory!.categoryName
            navigationController?.navigationBar.barTintColor = UIColor(hexString: color) //changing the navbar color
            searchBar.barTintColor = UIColor(hexString: color) //changing the search bar background color
            searchBar.placeholder = "Search for To-Dos"
            navigationController?.navigationBar.tintColor = ContrastColorOf(UIColor(hexString: color)!, returnFlat: true) //adding contrast to navbar items
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(UIColor(hexString: color)!, returnFlat: true)] //adding contrast to navbar title
        }
    }
    
    
    
    //MARK: - Create TableView Data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int ) -> Int {
        return itemArray?.count ?? 1 //will create as many cells in the table view as there are cells in the itemArray
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let tempItem = itemArray?[indexPath.row] {
        
        cell.textLabel?.text = tempItem.title
        
            if let color = UIColor(hexString: selectedCategory!.categoryColor)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(itemArray!.count)) { //creating gradient for todo list items. only works if UIColor for hex string result is not nil.
                  cell.backgroundColor = color
                  cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true) //using the chameleon framework functionality to make the text stand out no matter the background color.
                  cell.tintColor = ContrastColorOf(color, returnFlat: true) //made the checkmarks contrast as well.
            }
          
        
        if tempItem.isDone == true { //setting checkmarks depending on the value of isDone
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
                print("error setting isDone")
            }
            
        }
        
        tableView.reloadData()
       
        tableView.deselectRow(at: indexPath, animated: true) //makes the cells flash gray and then go back to white after being clicked.
       
    }
    
    /* !!! --no longer used. will update this method later --- UPDATED to use SwipeTableViewController superclass with SwipeCellKit
     
    
    
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
    
    
    //MARK: - create add new items functionality
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let textAlert = UIAlertController(title: "Add New To-Do Item", message: "", preferredStyle: .alert)
        
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
            alertTextField.placeholder = "Create New To-Do"
            textField = alertTextField //will hold the text that user has entered
        }
            
            textAlert.addAction(action)
            present(textAlert, animated:true, completion: nil)
            
        }
    
    
    func loadData() {
        itemArray = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

        tableView.reloadData()

    }
    
    override func updateModel(at indexPath: IndexPath) { //overriding the function from the SwipeTableViewController
        if let item = itemArray?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(item)
                }
            } catch {
                print("Error deleting cell")
            }
        }
    }

    
    
}


//----------------------------- ENABLING SEARCH BAR FUNCTIONALITY ----------------------------


extension TBviewController: UISearchBarDelegate { //can extend the class's functionality this wayinstead of adding the delegate directly to the class


    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            itemArray = itemArray?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true) //simple search with realm
        
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
