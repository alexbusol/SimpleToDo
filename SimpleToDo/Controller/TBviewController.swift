//
//  ViewController.swift
//  SimpleToDo
//
//  Created by Alex Busol on 7/4/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit
import CoreData

class TBviewController: UITableViewController { //change the subclass to uitableViewController to link it to the table viewC in the mainStoryboard.
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext //getting the context from the app delegate.
    var itemArray = [Item]() //array of objects of Item Entities in Core Data
    //let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist") //creates our own plist at the app's location. -- no longer needed
    
    //let defaults = UserDefaults.standard - cant user with custom datatypes
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))

        
        //USER DEFAULTS rejects custom data types.
        //need to think of anyther way of storing data on the device.
        
        
//        if let items = defaults.array(forKey: "ToDoListArray") as? [ItemClass] { //make sure that the storage instance exists
//            itemArray = items //when the app is done loading, we retrieve the information from the previous session
//        }
        // Do any additional setup after loading the view, typically from a nib.
        
        loadData()
    }

    //MARK - Create TableView Data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int ) -> Int {
        return itemArray.count //will create as many cells in the table view as there are cells in the itemArray
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let tempItem = itemArray[indexPath.row]
        
        cell.textLabel?.text = tempItem.title
        
        if tempItem.isDone == true {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
       
        return cell
    }
    
    //MARK - Create table view delegate methods. ADD CHECKMARKS ON CLICKED ITEMS. ANIMATE THE SELECTED ROW
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(itemArray[indexPath.row])
        
        /* --remove the item when done.
        context.delete(itemArray[indexPath.row]) //order matters. call this first before removing the item form the array.
         
        itemArray.remove(at: indexPath.row)
        
        saveData()
        */
        
        itemArray[indexPath.row].isDone = !itemArray[indexPath.row].isDone //toggles between true and false every time the table cell is pressed
        saveData()
        
        //-------------NO LONGER USED BECAUSE WE ARE USING CUSTOM DATATYPE NOW-----------------
        /*
        if (tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark) { //points to a cell that is currently selected.
            tableView.cellForRow(at: indexPath)?.accessoryType = .none //removes the checkmark if the cell already has one.
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark //adds a checkmark to the cell that was clicked
        }
        
        */
        tableView.deselectRow(at: indexPath, animated: true) //makes the cells flash gray and then go back to white after being clicked.
        //at this point, we already have a very simple toDo app.
    }
    
    
    
    //----------------------enabling SLIDE TO DELETE------------------------
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
        
            context.delete(itemArray[indexPath.row]) //order matters. call this first before removing the item form the array.
            itemArray.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // saveData() - not needed because deleteRows already reorders the tableView

        }
    }
    
    
    
    //MARK - create add new items functionality
    //created IBaction from main.storyboard.
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        //want to show a popup with a text field where the user can write
        //his reminder text
        var textField = UITextField()
        let textAlert = UIAlertController(title: "Add a new toDo item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            print("success")
            
           //let tempItem = ItemClass() - no longer used
            
            //------------------ CREATING AND INITIALISING A NEW TODO ITEM --------------------
            let tempItem = Item(context: self.context)
            tempItem.title = textField.text!
            tempItem.isDone = false
            
            self.itemArray.append(tempItem) //ADDING THE ITEM TO THE EXISTING ARRAY OF ITEM ENTITIES
            
//            self.defaults.set(self.itemArray, forKey: "ToDoListArray") //saves the item in the persistance storage (UserDefaults) --no longer works with custom datatypess
            
            self.saveData()
        }
        
    
        //the alert will have a text field that the user can fill
        textAlert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField //will hold the text that user has entered
        }
            
            textAlert.addAction(action)
            present(textAlert, animated:true, completion: nil)
            
        }
   
    func saveData() {
        //let encoder = PropertyListEncoder() - no longer used
        do {
           try context.save()
        } catch {
            print("Error saving Context \(error)")
        }
        
        tableView.reloadData() //refreshes the table view to include the new user-added item.
    }
    
//    func loadData() {
//        do {
//            if let data = try? Data(contentsOf: dataFilePath!) {
//          //let decoder = PropertyListDecoder() - no longer used
//            try itemArray = decoder.decode([ItemClass].self, from: data)
//            }
//        } catch {
//            print("error decoding data")
//
//        }
//    }
    // now the app will pull items form the CoreData database when it loads
    func loadData() {
        let request : NSFetchRequest<Item> = Item.fetchRequest() //have to specify the datatype of output here
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("error fetching data from context \(error)")
        }
        
        
    
    }
    //ENABLING SEARCH BAR FUNCTIONALITY.
    
    
}

extension TBviewController: UISearchBarDelegate { //can extend the class's functionality this wayinstead of adding the delegate directly to the class
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        print(searchBar.text) //prints out the text that the user enters in the search bar.
        
        request.predicate  = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!) //the string means to look for items whose titles contain searchBar.text!
        //cd makes the search bar insensitive to case and diacrytics
        
        
        //SORT THE DATA WE GET BACK
        
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true) //sort in alphabetical order
        request.sortDescriptors = [sortDescriptor] //expects an array of sort descriptors, so we are passing an array of one
        
        
        //fetch the search results
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("error fetching data from the search results \(error)")
        }
        tableView.reloadData()
        
    }
    
    //when the text changed and went down to 0
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadData()
            tableView.reloadData()
            
            DispatchQueue.main.async { //select the main thread of exectuion. forces the code inside to run in the foreground.
                searchBar.resignFirstResponder() //deselects the search bar and dismisses the keyboard.
            }
            
        }
    }
}
